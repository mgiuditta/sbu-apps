import SbuKit
import SwiftUI

/// The clinometer's needle, pointing up away from gravity, and the wedge between the nearest 0°
/// mark and the needle. Decorative: the angle is in the figure.
struct ClinometerNeedle: View {
    /// Calibrated device rotation in degrees (see `Gravity.rotation`).
    let rotation: Double
    /// The dial's turn, 0 or 90 (see `DialGeometry`).
    var dialTurn = 0.0

    var body: some View {
        Canvas { context, size in
            let radius = min(size.width, size.height) / 2
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            let start = DialGeometry.wedgeStart(rotation: rotation, dialTurn: dialTurn)
            let sweep = DialGeometry.wedgeSweep(rotation: rotation, dialTurn: dialTurn)
            let needle = start + sweep
            let reach = radius - SbuTheme.space2

            var wedge = Path()
            wedge.move(to: center)
            let steps = max(1, Int(abs(sweep).rounded(.up)))
            for step in 0...steps {
                let position = start + sweep * Double(step) / Double(steps)
                wedge.addLine(to: DialPoint.at(position, radius: reach, around: center))
            }
            wedge.closeSubpath()
            context.fill(wedge, with: .color(SbuTheme.line))

            // The 0° line stops short of the 0° mark, so it does not strike through it.
            var zero = Path()
            zero.move(to: center)
            zero.addLine(to: DialPoint.at(start, radius: radius - SbuTheme.space12, around: center))
            context.stroke(zero, with: .color(SbuTheme.inkMuted), lineWidth: SbuTheme.hairline)

            // The needle breaks where the 0°, 45° and 90° marks sit, so it never strikes through one,
            // and picks up again across the ticks to point at the exact degree.
            var hand = Path()
            hand.move(to: center)
            hand.addLine(to: DialPoint.at(needle, radius: radius - SbuTheme.space12, around: center))
            hand.move(to: DialPoint.at(needle, radius: radius - SbuTheme.space4, around: center))
            hand.addLine(to: DialPoint.at(needle, radius: radius, around: center))
            context.stroke(hand, with: .color(SbuTheme.ink), style: StrokeStyle(lineWidth: SbuTheme.hairline * 2, lineCap: .round))

            let hub = SbuTheme.space2
            context.fill(
                Path(ellipseIn: CGRect(x: center.x - hub / 2, y: center.y - hub / 2, width: hub, height: hub)),
                with: .color(SbuTheme.ink)
            )
        }
        .accessibilityHidden(true)
    }
}

#Preview("Light") {
    ClinometerNeedle(rotation: 32.4)
        .padding(SbuTheme.space4)
        .background(SbuTheme.surface)
}

#Preview("Dark") {
    ClinometerNeedle(rotation: -150)
        .padding(SbuTheme.space4)
        .background(SbuTheme.surface)
        .preferredColorScheme(.dark)
}
