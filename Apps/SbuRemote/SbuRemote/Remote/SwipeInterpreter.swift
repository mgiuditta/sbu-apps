import CoreGraphics

/// Turns a finger on the touchpad into arrow keys: one step each time the finger travels
/// `stepDistance` in its dominant direction, repeating while it keeps going; a touch that
/// barely moves is a tap, which is OK.
nonisolated struct SwipeInterpreter: Sendable {
    let stepDistance: CGFloat
    let tapSlop: CGFloat

    private var origin: CGPoint?
    private var start: CGPoint?
    private var stepped = false

    init(stepDistance: CGFloat = 40, tapSlop: CGFloat = 10) {
        self.stepDistance = stepDistance
        self.tapSlop = tapSlop
    }

    /// The arrows the finger has earned since the last call.
    mutating func move(to point: CGPoint) -> [RemoteKey] {
        guard let origin else {
            self.origin = point
            start = point
            return []
        }
        let dx = point.x - origin.x
        let dy = point.y - origin.y
        let horizontal = abs(dx) >= abs(dy)
        let distance = horizontal ? abs(dx) : abs(dy)
        let steps = Int(distance / stepDistance)
        guard steps > 0 else { return [] }

        let key: RemoteKey = horizontal ? (dx > 0 ? .right : .left) : (dy > 0 ? .down : .up)
        // Advance along the dominant axis by whole steps; the other axis follows the finger,
        // so a slightly slanted swipe does not turn into a stray step sideways later.
        let travelled = CGFloat(steps) * stepDistance
        self.origin = horizontal
            ? CGPoint(x: origin.x + (dx > 0 ? travelled : -travelled), y: point.y)
            : CGPoint(x: point.x, y: origin.y + (dy > 0 ? travelled : -travelled))
        stepped = true
        return Array(repeating: key, count: steps)
    }

    /// Ends the touch: `.select` when it was a tap, nothing after a swipe.
    mutating func end(at point: CGPoint) -> RemoteKey? {
        defer {
            origin = nil
            start = nil
            stepped = false
        }
        guard !stepped, let start else { return nil }
        let moved = hypot(point.x - start.x, point.y - start.y)
        return moved <= tapSlop ? .select : nil
    }
}
