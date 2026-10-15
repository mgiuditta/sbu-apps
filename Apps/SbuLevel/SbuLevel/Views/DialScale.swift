import SbuKit
import SwiftUI

/// The dial's ring of ticks, one every 2° and a longer one every 10°, with the 0°, 45° and 90°
/// marks of the clinometer when `showsValues` is on. Decorative.
struct DialScale: View {
    /// The quarter marks: 0° at the top and bottom, 90° at the sides, 45° between.
    private static let labelPositions = stride(from: 0.0, to: 360, by: 45)

    let showsValues: Bool
    /// The dial's turn, 0 or 90 (see `DialGeometry`).
    var dialTurn = 0.0

    var body: some View {
        Canvas { context, size in
            let radius = min(size.width, size.height) / 2
            let center = CGPoint(x: size.width / 2, y: size.height / 2)

            context.stroke(
                Path(ellipseIn: CGRect(x: center.x - radius, y: center.y - radius, width: radius * 2, height: radius * 2)),
                with: .color(SbuTheme.line),
                lineWidth: SbuTheme.hairline
            )

            for position in stride(from: 0.0, to: 360, by: 2) {
                let isMajor = position.truncatingRemainder(dividingBy: 10) == 0
                let length = isMajor ? SbuTheme.space3 : SbuTheme.space2
                var tick = Path()
                tick.move(to: DialPoint.at(position, radius: radius, around: center))
                tick.addLine(to: DialPoint.at(position, radius: radius - length, around: center))
                context.stroke(tick, with: .color(isMajor ? SbuTheme.inkMuted : SbuTheme.line), lineWidth: SbuTheme.hairline)
            }

            guard showsValues else { return }
            let labelRadius = radius - SbuTheme.space3 - SbuTheme.space5
            for position in Self.labelPositions {
                let value = DialGeometry.value(at: position, dialTurn: dialTurn)
                let label = Text(verbatim: value.formatted(.number.precision(.fractionLength(0))) + "°")
                    .font(SbuTheme.caption.monospacedDigit())
                    .foregroundStyle(SbuTheme.inkMuted)
                context.draw(label, at: DialPoint.at(position, radius: labelRadius, around: center))
            }
        }
        .accessibilityHidden(true)
    }
}

#Preview("Light") {
    DialScale(showsValues: true)
        .padding(SbuTheme.space4)
        .background(SbuTheme.surface)
}

#Preview("Dark") {
    DialScale(showsValues: true)
        .padding(SbuTheme.space4)
        .background(SbuTheme.surface)
        .preferredColorScheme(.dark)
}
