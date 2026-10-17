import SbuKit
import SwiftUI

/// Moonrise and moonset for the day shown, in a card on the paper, and the place they are for. A
/// city in another time zone says whose clock the times are on. Without a place, one pill offers
/// to show them.
struct RiseSetView: View {
    let times: PlaceRiseSet?
    let placeName: String?
    let choosePlace: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: SbuTheme.space2) {
            if let times, let placeName {
                SbuListCard(RiseSetFacts.facts(for: times.riseSet)) { fact in
                    MoonFactRow(fact)
                }
                // Text(_:format:) takes the clock from the environment, not from the format.
                .environment(\.timeZone, times.timeZone)

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
        .sbuPaper(grid: true)
    }
}
