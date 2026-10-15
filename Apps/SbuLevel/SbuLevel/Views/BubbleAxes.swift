import SbuKit
import SwiftUI

/// The bubble's tilt along each axis of the screen, in the chosen unit: secondary to the figure,
/// in `inkMuted`.
struct BubbleAxes: View {
    let tiltX: Double
    let tiltY: Double
    let unit: AngleUnit

    private var style: AngleFormatStyle { AngleFormatStyle(unit: unit) }

    var body: some View {
        HStack(spacing: SbuTheme.space6) {
            axis(tiltX, systemImage: "arrow.left.and.right")
            axis(tiltY, systemImage: "arrow.up.and.down")
        }
        .font(SbuTheme.footnote.monospacedDigit())
        .foregroundStyle(SbuTheme.inkMuted)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("Asse orizzontale \(style.spokenText(abs(tiltX))), asse verticale \(style.spokenText(abs(tiltY)))"))
    }

    private func axis(_ tilt: Double, systemImage: String) -> some View {
        Label {
            Text(verbatim: style.format(abs(tilt)) + (unit.symbol ?? ""))
        } icon: {
            Image(systemName: systemImage)
                .fontWeight(.medium)
                .imageScale(.medium)
        }
    }
}

#Preview("Light") {
    BubbleAxes(tiltX: 2.9, tiltY: -1.7, unit: .degrees)
        .padding(SbuTheme.space4)
        .background(SbuTheme.surface)
}

#Preview("Dark") {
    BubbleAxes(tiltX: 2.9, tiltY: -1.7, unit: .percent)
        .padding(SbuTheme.space4)
        .background(SbuTheme.surface)
        .preferredColorScheme(.dark)
}
