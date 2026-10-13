import SbuKit
import SwiftUI

/// Moonrise and moonset for the day shown, secondary like the other facts, and the place they
/// are for. A city in another time zone says whose clock the times are on. Without a place, one
/// pill offers to show them.
struct RiseSetView: View {
    let times: PlaceRiseSet?
    let placeName: String?
    let choosePlace: () -> Void

    var body: some View {
        VStack(spacing: SbuTheme.space2) {
            if let times, let placeName {
                RiseSetRows(riseSet: times.riseSet, timeZone: times.timeZone)

                if times.isOtherTimeZone {
                    Text("Ora locale di \(placeName)")
                        .font(SbuTheme.footnote)
                        .foregroundStyle(SbuTheme.inkMuted)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                PlacePill(title: Text(verbatim: placeName), action: choosePlace)
                    .accessibilityLabel(Text("Luogo: \(placeName)"))
                    .accessibilityHint("Scegli un altro luogo")
                    .padding(.top, SbuTheme.space2)
            } else {
                PlacePill(title: Text("Mostra sorgere e tramonto"), action: choosePlace)
            }
        }
    }
}

/// The pill that opens the place sheet.
private struct PlacePill: View {
    let title: Text
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Label {
                title
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

/// The two rows, or one when the moon stays on one side of the horizon all day.
private struct RiseSetRows: View {
    let riseSet: MoonRiseSet
    let timeZone: TimeZone

    private var format: Date.FormatStyle {
        var format = Date.FormatStyle.dateTime.hour().minute()
        format.timeZone = timeZone
        return format
    }

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
            Text(date, format: format)
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
    private static let rome = Coordinates(latitude: 41.8933, longitude: 12.4828)
    private static let newYork = Coordinates(latitude: 40.7128, longitude: -74.0060)

    var body: some View {
        VStack(spacing: SbuTheme.space8) {
            RiseSetView(
                times: PlaceRiseSet(shownDate: .now, coordinates: Self.rome, timeZone: nil, deviceCalendar: .current),
                placeName: "Roma"
            ) {}
            RiseSetView(
                times: PlaceRiseSet(shownDate: .now, coordinates: Self.newYork, timeZone: TimeZone(identifier: "America/New_York"), deviceCalendar: .current),
                placeName: "New York"
            ) {}
            RiseSetView(times: nil, placeName: nil) {}
        }
        .padding(SbuTheme.space4)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(SbuTheme.surface)
    }
}
