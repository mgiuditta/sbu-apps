import SbuKit
import SwiftUI

/// The dial over the trip: under the figure in portrait, beside it in landscape.
/// At accessibility text sizes the dial, only a drawing of the figure, gives its room to the text.
struct DialAndTrip: View {
    let model: SpeedModel

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        VStack(spacing: SbuTheme.space6) {
            if !dynamicTypeSize.isAccessibilitySize {
                SpeedGauge(fraction: model.dialFraction)
                    .frame(maxWidth: 240)
            }

            TripSummary(trip: model.trip, unit: model.unit)
        }
    }
}

#Preview("Light") {
    DialAndTrip(model: SpeedModel())
        .padding(SbuTheme.space4)
        .background(SbuTheme.surface)
        .tint(SbuTheme.accentSpeed)
}

#Preview("Dark") {
    DialAndTrip(model: SpeedModel())
        .padding(SbuTheme.space4)
        .background(SbuTheme.surface)
        .tint(SbuTheme.accentSpeed)
        .preferredColorScheme(.dark)
}
