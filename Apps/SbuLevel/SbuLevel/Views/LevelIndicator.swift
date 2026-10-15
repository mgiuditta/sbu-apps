import SbuKit
import SwiftUI

/// The instrument: a clinometer dial with needle and wedge on an edge, a bubble level when flat,
/// cross-fading between the two. On an edge, dragging the dial round turns it a quarter, to read
/// 0° at the sides; VoiceOver turns it with the adjustable action. The angle is in the figure.
struct LevelIndicator: View {
    let reading: LevelReading
    /// Turns the dial after a drag of so many degrees; `nil` keeps it fixed.
    var turnDial: ((Double) -> Void)?
    /// The full-screen action VoiceOver offers on the dial, and its name.
    var fullScreenAction: LocalizedStringKey = "Schermo intero"
    var toggleFullScreen: (() -> Void)?

    @State private var dragAngle = 0.0
    @State private var size = CGSize.zero

    private var isEdge: Bool { reading.mode == .edge }

    private var turnsDial: Bool { isEdge && turnDial != nil }

    private var dialValue: LocalizedStringKey {
        reading.dialTurn == 0 ? "0° sui bordi in alto e in basso" : "0° sui lati"
    }

    var body: some View {
        ZStack {
            ClinometerNeedle(rotation: reading.rotation, dialTurn: reading.dialTurn)
                .opacity(isEdge && dragAngle == 0 ? 1 : 0)

            DialScale(showsValues: isEdge, dialTurn: reading.dialTurn)
                .rotationEffect(.degrees(dragAngle))

            BubbleView(bubbleX: reading.bubbleX, bubbleY: reading.bubbleY)
                .opacity(isEdge ? 0 : 1)
        }
        .animation(.easeInOut, value: reading.mode)
        .aspectRatio(1, contentMode: .fit)
        // The dial's marks have a fixed place on the ring: past this size they would overlap.
        .dynamicTypeSize(...DynamicTypeSize.xxLarge)
        .onGeometryChange(for: CGSize.self) { proxy in
            proxy.size
        } action: { newSize in
            size = newSize
        }
        .contentShape(.circle)
        // Alongside, not over, the tap that hides the controls: a drag moves too far to be a tap.
        .simultaneousGesture(dragToTurn)
        .onTapGesture {
            toggleFullScreen?()
        }
        .accessibilityElement()
        .accessibilityLabel(Text("Quadrante"))
        .accessibilityValue(Text(dialValue))
        .accessibilityAdjustableAction { _ in
            turnDial?(DialGeometry.quarterTurn)
        }
        .accessibilityAction(named: Text(fullScreenAction)) {
            toggleFullScreen?()
        }
        // Last: an accessibility modifier after it would bring the element back.
        .accessibilityHidden(turnsDial == false)
    }

    private var dragToTurn: some Gesture {
        DragGesture(minimumDistance: SbuTheme.space2)
            .onChanged { value in
                guard turnsDial else { return }
                dragAngle = Angles.normalized(position(of: value.location) - position(of: value.startLocation))
            }
            .onEnded { _ in
                guard turnsDial else { return }
                turnDial?(dragAngle)
                withAnimation(.easeOut) {
                    dragAngle = 0
                }
            }
    }

    /// Degrees clockwise from the top of the dial, around its center.
    private func position(of point: CGPoint) -> Double {
        Angles.degrees(fromRadians: atan2(point.x - size.width / 2, size.height / 2 - point.y))
    }
}

#Preview("Light") {
    LevelIndicatorPreview()
}

#Preview("Dark") {
    LevelIndicatorPreview()
        .preferredColorScheme(.dark)
}

private struct LevelIndicatorPreview: View {
    var body: some View {
        VStack(spacing: SbuTheme.space6) {
            LevelIndicator(reading: LevelReading(gravity: .standing(rotatedBy: 32.4), calibration: .none, dialTurn: 90))
            LevelIndicator(reading: LevelReading(gravity: .lying(tiltedBy: 3), calibration: .none))
        }
        .padding(SbuTheme.space4)
        .background(SbuTheme.surface)
    }
}
