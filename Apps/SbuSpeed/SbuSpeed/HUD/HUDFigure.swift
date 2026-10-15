import SbuKit
import SwiftUI

/// The HUD's figure: as large as the screen allows, closed by the full stop, mirrored for the
/// windshield, with the over-limit line under it. VoiceOver reads it unmirrored, as on the tool screen.
struct HUDFigure: View {
    /// Widths of the figure in ems: three digits of Bricolage Grotesque ExtraBold and the unit and
    /// full stop beside them take about 2.6 times the font size, and the line under it 1.6 in height.
    private static let widthInEms = 2.6
    private static let heightInEms = 1.6

    let model: SpeedModel

    private var figure: String { SpeedFigureStyle(unit: model.unit).format(model.speed) }

    private var spokenSpeed: String {
        model.speed.map { model.unit.speedText(metersPerSecond: $0) } ?? String(localized: "Cerco il segnale GPS")
    }

    var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width / Self.widthInEms, geometry.size.height / Self.heightInEms)
            VStack(spacing: SbuTheme.space4) {
                HStack(alignment: .firstTextBaseline, spacing: 0) {
                    Text(verbatim: figure)
                        .font(SbuTheme.numberFont(size: size))
                        .tracking(SbuTheme.statHeroTracking)
                        .padding(.trailing, -SbuTheme.statHeroTracking)
                        .foregroundStyle(SbuTheme.ink)
                        .contentTransition(.numericText())

                    // The unit keeps the tool screen's ratio to the figure.
                    Text(verbatim: model.unit.symbol)
                        .font(SbuTheme.smallNumberFont(size: size * SbuTheme.statSmallSize / SbuTheme.statHeroSize))
                        .foregroundStyle(SbuTheme.inkMuted)

                    SbuFullStop(fontSize: size)
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
        .background(SbuTheme.surface)
        .tint(SbuTheme.accentSpeed)
}

#Preview("Dark") {
    HUDFigure(model: SpeedModel())
        .background(SbuTheme.surface)
        .tint(SbuTheme.accentSpeed)
        .preferredColorScheme(.dark)
}
