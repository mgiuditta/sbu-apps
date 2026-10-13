import SbuKit
import SwiftUI

/// Moonrise and moonset for the day shown, secondary like the other facts, and the place they
/// are for. Without a place, one pill offers to show them.
struct RiseSetView: View {
    let riseSet: MoonRiseSet?
    let placeName: Text?
    let choosePlace: () -> Void

    var body: some View {
        VStack(spacing: SbuTheme.space2) {
            if let riseSet, let placeName {
                RiseSetRows(riseSet: riseSet)

                Button(action: choosePlace) {
                    Label {
                        placeName
                    } icon: {
                        Image(systemName: "location")
                            .fontWeight(.medium)
                            .imageScale(.medium)
                    }
                }
                .buttonStyle(SbuFieldPillStyle())
                .accessibilityLabel(Text("Luogo: \(placeName)"))
                .accessibilityHint("Scegli un altro luogo")
                .accessibilityIdentifier("place")
            } else {
                Button(action: choosePlace) {
                    Label {
                        Text("Mostra sorgere e tramonto")
                    } icon: {
                        Image(systemName: "location")
                            .fontWeight(.medium)
                            .imageScale(.medium)
                    }
                }
                .buttonStyle(SbuFieldPillStyle())
                .accessibilityIdentifier("place")
            }
        }
    }
}

/// The two rows, or one when the moon stays on one side of the horizon all day.
private struct RiseSetRows: View {
    let riseSet: MoonRiseSet

    var body: some View {
        switch riseSet {
        case let .crosses(rise, set):
            MoonFactRow("Sorge", value: time(rise, missing: "Non sorge oggi"))
            MoonFactRow("Tramonta", value: time(set, missing: "Non tramonta oggi"))
        case .aboveAllDay:
            MoonFactRow("Sorgere e tramonto", value: Text("Sopra l'orizzonte tutto il giorno"))
        case .belowAllDay:
            MoonFactRow("Sorgere e tramonto", value: Text("Sotto l'orizzonte tutto il giorno"))
        }
    }

    private func time(_ date: Date?, missing: LocalizedStringKey) -> Text {
        if let date {
            Text(date, format: .dateTime.hour().minute())
        } else {
            Text(missing)
        }
    }
}

#Preview("Light") {
    RiseSetPreview()
}

#Preview("Dark") {
    RiseSetPreview()
        .preferredColorScheme(.dark)
}

private struct RiseSetPreview: View {
    var body: some View {
        VStack(spacing: SbuTheme.space8) {
            RiseSetView(
                riseSet: .crosses(rise: .now, set: .now.addingTimeInterval(11 * 3_600)),
                placeName: Text(verbatim: "Roma")
            ) {}
            RiseSetView(riseSet: .crosses(rise: nil, set: .now), placeName: Text(verbatim: "Oslo")) {}
            RiseSetView(riseSet: .aboveAllDay, placeName: Text(verbatim: "Longyearbyen")) {}
            RiseSetView(riseSet: nil, placeName: nil) {}
        }
        .padding(SbuTheme.space4)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(SbuTheme.surface)
    }
}
