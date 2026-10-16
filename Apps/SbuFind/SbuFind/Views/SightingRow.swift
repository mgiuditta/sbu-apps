import SbuKit
import SwiftUI

/// A device heard before and not heard now: its symbol, its name and how long ago.
struct SightingRow: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    let sighting: Sighting

    @ScaledMetric(relativeTo: .headline) private var symbolSide = SbuTheme.controlRound

    var body: some View {
        HStack(spacing: SbuTheme.space4) {
            if !dynamicTypeSize.isAccessibilitySize {
                Image(systemName: sighting.kind.systemImage)
                    .font(SbuTheme.headline)
                    .fontWeight(.medium)
                    .imageScale(.large)
                    .foregroundStyle(SbuTheme.inkMuted)
                    .frame(width: symbolSide, height: symbolSide)
                    .accessibilityHidden(true)
            }

            VStack(alignment: .leading, spacing: SbuTheme.space1) {
                Text(verbatim: sighting.name)
                    .font(SbuTheme.headline)
                    .foregroundStyle(SbuTheme.ink)

                Text(sighting.date, format: .relative(presentation: .named))
                    .font(SbuTheme.subheadline)
                    .foregroundStyle(SbuTheme.inkMuted)
                    // The whole width: the text updates itself and grows, "9 secondi" to "13 secondi".
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            Spacer(minLength: 0)
        }
        .padding(.vertical, SbuTheme.space1)
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("sighting")
    }
}

#Preview("Light") {
    List {
        SightingRow(sighting: Sighting(id: UUID(), name: "Buds Pro", kind: .earbuds, date: .now.addingTimeInterval(-2520), place: FixedLocationProvider.demo))
    }
}

#Preview("Dark") {
    List {
        SightingRow(sighting: Sighting(id: UUID(), name: "Forerunner 255", kind: .watch, date: .now.addingTimeInterval(-7200), place: FixedLocationProvider.demo))
    }
    .preferredColorScheme(.dark)
}
