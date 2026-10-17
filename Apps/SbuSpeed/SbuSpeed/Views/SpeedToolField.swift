import SbuKit
import SwiftUI

/// The figure zone: the speed as the figure and the over-limit line, under `SpeedTitle`.
/// The full stop is grey while the GPS has no speed, in the accent once it reads one. Salvato
/// closes the figure when a trip is kept.
struct SpeedToolField: View {
    let model: SpeedModel
    /// Set once per trip kept in Viaggi.
    @Binding var isClosing: Bool

    /// With knots the speed is SOG, speed over ground, as on a chart plotter.
    private var caption: LocalizedStringResource {
        model.unit == .knots ? "SOG" : "Velocità"
    }

    private var statusText: LocalizedStringResource {
        switch model.status {
        case .needsAccess: "Consenti la posizione"
        case .denied: "Posizione non consentita"
        case .approximate: "Serve la posizione esatta"
        case .searching: "Cerco il segnale GPS"
        case .still: "Fermo"
        case .moving: "In movimento"
        }
    }

    /// The unit and what the GPS is doing, under the figure: "km/h · In movimento".
    private var context: Text {
        Text(verbatim: "\(model.unit.symbol) · \(String(localized: statusText))")
    }

    /// What VoiceOver reads for the figure: what it measures, the speed in words, and the status.
    private var spokenFigure: String {
        var parts = [String(localized: caption)]
        if let speed = model.speed {
            parts.append(model.unit.speedText(metersPerSecond: speed))
        }
        parts.append(String(localized: statusText))
        return parts.joined(separator: ", ")
    }

    var body: some View {
        VStack(alignment: .leading, spacing: SbuTheme.space3) {
            SbuFigure(
                value: SpeedFigureStyle(unit: model.unit).format(model.speed),
                fullStop: model.speed == nil ? .waiting : .set,
                context: context,
                accessibilityLabel: Text(verbatim: spokenFigure)
            )
            .sbuClosure($isClosing, word: "Salvato")

            if model.isOverLimit, let limit = model.speedLimit {
                // The warning is a word and a symbol in `danger`; the figure stays in ink.
                Label("Oltre il limite di \(limit.text())", systemImage: "exclamationmark.triangle")
                    .font(SbuTheme.headline)
                    .foregroundStyle(SbuTheme.danger)
            }
        }
    }
}

#Preview("Light") {
    ScrollView {
        SpeedToolField(model: SpeedModel(), isClosing: .constant(false))
            .padding(SbuTheme.space4)
            .sbuPaper()
    }
    .environment(\.sbuAccent, .speed)
}

#Preview("Dark") {
    ScrollView {
        SpeedToolField(model: SpeedModel(), isClosing: .constant(false))
            .padding(SbuTheme.space4)
            .sbuPaper()
    }
    .environment(\.sbuAccent, .speed)
    .preferredColorScheme(.dark)
}
