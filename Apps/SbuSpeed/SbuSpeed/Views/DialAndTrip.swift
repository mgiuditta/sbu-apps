import SbuKit
import SwiftUI

/// Altitude and course, the dial over the trip, and the quick limits: under the figure in portrait, beside it in landscape.
/// At accessibility text sizes the dial, only a drawing of the figure, gives its room to the text.
struct DialAndTrip: View {
    let model: SpeedModel
    /// In landscape the quick limits sit under the figure instead, or the dial has no height left.
    var showsLimits = true

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        VStack(spacing: SbuTheme.space6) {
            NavigationLine(reading: model.navigation, unit: model.unit)

            if !dynamicTypeSize.isAccessibilitySize {
                SpeedGauge(fraction: model.dialFraction)
                    .frame(maxWidth: 240)
            }

            TripSummary(trip: model.trip, unit: model.unit)

            if showsLimits {
                QuickLimitPills(model: model)
            }
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
