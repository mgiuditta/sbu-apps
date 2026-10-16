import MapKit
import SbuKit
import SwiftUI

/// Where the iPhone was when it last heard the device, on a map, as in Wunderfind's map view:
/// "Visto l'ultima volta 42 minuti fa", and a pin. The note says it is a place to start
/// looking, not the device's position.
struct LastSeenCard: View {
    let sighting: Sighting

    private var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: sighting.place.latitude, longitude: sighting.place.longitude)
    }

    private var region: MKCoordinateRegion {
        // At least 150 m across, wider when the position was vague.
        let span = max(150, sighting.place.accuracy * 4)
        return MKCoordinateRegion(center: coordinate, latitudinalMeters: span, longitudinalMeters: span)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: SbuTheme.space2) {
            VStack(alignment: .leading, spacing: 0) {
                Text("Visto l'ultima volta")
                    .font(SbuTheme.headline)
                    .foregroundStyle(SbuTheme.ink)

                Text(sighting.date, format: .relative(presentation: .named))
                    .font(SbuTheme.subheadline)
                    .foregroundStyle(SbuTheme.inkMuted)
                    // The whole width: the text updates itself and grows, "9 secondi" to "13 secondi".
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .accessibilityElement(children: .combine)

            Map(initialPosition: .region(region), interactionModes: [.pan, .zoom]) {
                Marker(sighting.name, systemImage: sighting.kind.systemImage, coordinate: coordinate)
                    .tint(SbuTheme.accentFind)
            }
            .frame(height: 180)
            .clipShape(.rect(cornerRadius: SbuTheme.radiusMd))
            .accessibilityLabel(Text("Mappa del punto in cui l'hai sentito l'ultima volta"))

            Text("È dove era il tuo iPhone quando l'ha sentito: da lì inizia a cercare.")
                .font(SbuTheme.footnote)
                .foregroundStyle(SbuTheme.inkMuted)
        }
        .padding(SbuTheme.space4)
        .background(SbuTheme.surfaceRaised, in: .rect(cornerRadius: SbuTheme.radiusLg))
    }
}

#Preview("Light") {
    LastSeenCard(sighting: Sighting(id: UUID(), name: "Buds Pro", kind: .earbuds, date: .now.addingTimeInterval(-2520), place: FixedLocationProvider.demo))
        .padding(SbuTheme.space4)
        .background(SbuTheme.surface)
        .tint(SbuTheme.accentFind)
}

#Preview("Dark") {
    LastSeenCard(sighting: Sighting(id: UUID(), name: "Buds Pro", kind: .earbuds, date: .now.addingTimeInterval(-2520), place: FixedLocationProvider.demo))
        .padding(SbuTheme.space4)
        .background(SbuTheme.surface)
        .tint(SbuTheme.accentFind)
        .preferredColorScheme(.dark)
}
