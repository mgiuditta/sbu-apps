import SbuKit
import SwiftUI

/// The HUD's figure: as large as the screen allows, closed by the full stop, mirrored for the
/// windshield, with the over-limit line under it. VoiceOver reads it unmirrored, as on the tool screen.
struct HUDFigure: View {
    /// Widths of the figure in ems, measured on Bricolage Grotesque at wght 800, wdth 100: three
    /// tabular digits take 1.83, the unit beside them in SF at the old 22/64 ratio about 0.76, so
    /// 2.6 with a margin. The full stop is a fixed square and gap, outside the ems. The line under
    /// it takes the height up to 1.6: ascent 0.93 and descent 0.27, then the over-limit line.
    private static let widthInEms = 2.6
    private static let heightInEms = 1.6
    /// The unit's size against the figure's, as on the v4 tool screen (22 over 64).
    private static let unitRatio = SbuTheme.statSmallSize / SbuTheme.statHeroSize
    /// The hero full stop and its gap, which do not grow with the figure.
    private static let fullStopWidth = SbuTheme.fullStopHero + SbuTheme.space3

    let model: SpeedModel

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var figure: String { SpeedFigureStyle(unit: model.unit).format(model.speed) }

    private var spokenSpeed: String {
        model.speed.map { model.unit.speedText(metersPerSecond: $0) } ?? String(localized: "Cerco il segnale GPS")
    }

    var body: some View {
        GeometryReader { geometry in
            let size = min((geometry.size.width - Self.fullStopWidth) / Self.widthInEms, geometry.size.height / Self.heightInEms)
            VStack(spacing: SbuTheme.space4) {
                HStack(alignment: .lastTextBaseline, spacing: 0) {
                    Text(verbatim: figure)
                        .font(.sbuFigure(size: size))
                        .foregroundStyle(SbuTheme.ink)
                        .contentTransition(.numericText())
                        .animation(SbuMotion.animation(SbuMotion.base, reduceMotion: reduceMotion), value: figure)

                    Text(verbatim: model.unit.symbol)
                        .font(SbuTheme.smallNumberFont(size: size * Self.unitRatio))
                        .foregroundStyle(SbuTheme.inkMuted)

                    SbuFullStop(model.speed == nil ? .waiting : .set, size: .hero)
                }
                .lineLimit(1)

                if model.isOverLimit, let limit = model.speedLimit {
                    Label("Oltre il limite di \(limit.text())", systemImage: "exclamationmark.triangle")
                        .font(SbuTheme.title2)
                        .fontWeight(.medium)
                        .foregroundStyle(SbuTheme.danger)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            // Mirrored left to right: the windshield turns it back.
            .scaleEffect(x: -1, y: 1)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Velocità")
        .accessibilityValue(model.isOverLimit ? Text("\(spokenSpeed), oltre il limite") : Text(verbatim: spokenSpeed))
    }
}

#Preview("Light") {
    HUDFigure(model: SpeedModel())
        .background(SbuTheme.paper)
        .environment(\.sbuAccent, .speed)
}

#Preview("Dark") {
    HUDFigure(model: SpeedModel())
        .background(SbuTheme.paper)
        .environment(\.sbuAccent, .speed)
        .preferredColorScheme(.dark)
}
