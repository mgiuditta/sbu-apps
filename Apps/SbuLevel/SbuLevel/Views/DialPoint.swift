import CoreGraphics
import Foundation

/// Points on the dial, by position in degrees clockwise from the top.
nonisolated enum DialPoint {
    static func at(_ position: Double, radius: CGFloat, around center: CGPoint) -> CGPoint {
        let radians = Angles.radians(fromDegrees: position)
        return CGPoint(x: center.x + radius * sin(radians), y: center.y - radius * cos(radians))
    }
}
