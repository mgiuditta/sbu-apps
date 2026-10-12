import SbuKit
import SwiftUI

/// Top speed, average speed and distance of the current trip: side by side, stacked at accessibility text sizes.
struct TripSummary: View {
    let trip: Trip
    let unit: SpeedUnit

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        let layout = dynamicTypeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(spacing: SbuTheme.space4))
            : AnyLayout(HStackLayout(alignment: .top, spacing: SbuTheme.space4))

        layout {
            TripValue(label: "Massima", value: unit.speedText(metersPerSecond: trip.maxSpeed))
            TripValue(label: "Media", value: unit.speedText(metersPerSecond: trip.averageSpeed))
            TripValue(label: "Distanza", value: unit.distanceText(meters: trip.distance))
        }
    }
}

#Preview("Light") {
    TripSummaryPreview()
}

#Preview("Dark") {
    TripSummaryPreview()
        .preferredColorScheme(.dark)
}

private struct TripSummaryPreview: View {
    var body: some View {
        TripSummary(trip: Trip(maxSpeed: 24.2, distance: 12_400, movingTime: 970), unit: .kilometersPerHour)
            .padding(SbuTheme.space4)
            .frame(maxHeight: .infinity)
            .background(SbuTheme.surface)
    }
}
