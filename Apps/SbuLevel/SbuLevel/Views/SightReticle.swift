import SbuKit
import SwiftUI

/// The sight's marks over the camera: a crosshair in the middle, the point the figure measures,
/// and the horizon through it, kept level as the iPhone rolls. Each line in `ink` over a wider
/// `surface` line, so it reads on any picture. Decorative: the angle is in the figure.
struct SightReticle: View {
    /// Calibrated device roll in degrees (see `Gravity.rotation`).
    let rotation: Double

    var body: some View {
        Canvas { context, size in
            let radius = min(size.width, size.height) / 2
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            let gap = SbuTheme.space2
            let arm = SbuTheme.space6

            var crosshair = Path()
            for position in [0.0, 90, 180, 270] {
                crosshair.move(to: DialPoint.at(position, radius: gap, around: center))
                crosshair.addLine(to: DialPoint.at(position, radius: gap + arm, around: center))
            }

            // The horizon turns against the iPhone, as the needle does, and stops short of the ring.
            let horizon = DialGeometry.needlePosition(rotation: rotation) + 90
            let reach = radius - SbuTheme.space3
            var line = Path()
            line.move(to: DialPoint.at(horizon, radius: gap + arm + gap, around: center))
            line.addLine(to: DialPoint.at(horizon, radius: reach, around: center))
            line.move(to: DialPoint.at(horizon + 180, radius: gap + arm + gap, around: center))
            line.addLine(to: DialPoint.at(horizon + 180, radius: reach, around: center))

            let halo = StrokeStyle(lineWidth: SbuTheme.hairline * 4, lineCap: .round)
            let stroke = StrokeStyle(lineWidth: SbuTheme.hairline * 2, lineCap: .round)
            for path in [crosshair, line] {
                context.stroke(path, with: .color(SbuTheme.surface), style: halo)
                context.stroke(path, with: .color(SbuTheme.ink), style: stroke)
            }
        }
        .accessibilityHidden(true)
    }
}

#Preview("Light") {
    SightReticle(rotation: 8)
        .frame(width: 300, height: 300)
        .background(SbuTheme.surfaceSunken)
}

#Preview("Dark") {
    SightReticle(rotation: -15)
        .frame(width: 300, height: 300)
        .background(SbuTheme.surfaceSunken)
        .preferredColorScheme(.dark)
}
