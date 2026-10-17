import SbuKit
import SwiftUI

/// A surface to swipe on: each step of the finger is an arrow, a tap is OK. On LG the finger
/// moves the TV's pointer instead. Raised paper with a `line` border, no shadow; a short mark in
/// `line` under the finger, off with Reduce Motion. Hidden from VoiceOver, which uses the D-pad.
struct TouchpadView: View {
    let session: RemoteSession

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var interpreter = SwipeInterpreter()
    @State private var touch: CGPoint?
    @State private var lastPointer: CGPoint?
    @State private var steps = 0

    private var hasPointer: Bool { session.client?.hasPointer ?? false }

    var body: some View {
        RoundedRectangle(cornerRadius: SbuTheme.radiusCard)
            .fill(SbuTheme.surfaceRaised)
            .strokeBorder(SbuTheme.line)
            .overlay {
                if let touch, !reduceMotion {
                    Circle()
                        .fill(SbuTheme.line)
                        .frame(width: SbuTheme.controlRoundSm, height: SbuTheme.controlRoundSm)
                        .position(touch)
                        .allowsHitTesting(false)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: SbuTheme.controlRound * 4)
            .contentShape(.rect)
            .gesture(drag)
            .sbuHaptic(.tick, trigger: steps)
            .opacity(session.status.acceptsKeys ? 1 : 0.5)
            .accessibilityHidden(true)
    }

    private var drag: some Gesture {
        DragGesture(minimumDistance: 0, coordinateSpace: .local)
            .onChanged { value in moved(to: value.location) }
            .onEnded { value in ended(at: value.location) }
    }

    private func moved(to point: CGPoint) {
        touch = point
        if hasPointer {
            if let lastPointer {
                let dx = point.x - lastPointer.x, dy = point.y - lastPointer.y
                Task { await session.run { try await $0.movePointer(dx: dx, dy: dy) } }
            }
            lastPointer = point
            _ = interpreter.move(to: point)
            return
        }
        let keys = interpreter.move(to: point)
        guard !keys.isEmpty else { return }
        steps += keys.count
        Task {
            for key in keys { await session.press(key) }
        }
    }

    private func ended(at point: CGPoint) {
        touch = nil
        lastPointer = nil
        // On LG every touch also moved the pointer, so only a real tap clicks.
        if interpreter.end(at: point) == .select {
            steps += 1
            Task { await session.run { try await $0.clickPointer() } }
        }
    }
}

#Preview("Light") {
    TouchpadView(session: .preview)
        .padding(SbuTheme.space4)
        .background(SbuTheme.paper)
}

#Preview("Dark") {
    TouchpadView(session: .preview)
        .padding(SbuTheme.space4)
        .background(SbuTheme.paper)
        .preferredColorScheme(.dark)
}
