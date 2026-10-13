import SbuKit
import SwiftUI

/// Top speed, average speed, distance and moving time of the current trip: two by two,
/// one under the other at accessibility text sizes.
struct TripSummary: View {
    let trip: Trip
    let unit: SpeedUnit

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        if dynamicTypeSize.isAccessibilitySize {
            VStack(spacing: SbuTheme.space4) {
                top
                average
                distance
                time
            }
        } else {
            // Not a ViewThatFits with a single row: the row never fits an iPhone with the time added,
            // and the hidden candidate fails the accessibility audit as clipped text.
            Grid(horizontalSpacing: SbuTheme.space4, verticalSpacing: SbuTheme.space4) {
                GridRow(alignment: .top) {
                    top
                    average
                }
                GridRow(alignment: .top) {
                    distance
                    time
                }
            }
        }
    }

    private var top: TripValue {
        TripValue(label: "Massima", value: unit.speedText(metersPerSecond: trip.maxSpeed))
    }

    private var average: TripValue {
        TripValue(label: "Media", value: unit.speedText(metersPerSecond: trip.averageSpeed))
    }

    private var distance: TripValue {
        TripValue(label: "Distanza", value: unit.distanceText(meters: trip.distance))
    }

    private var time: TripValue {
        TripValue(label: "Durata", value: trip.movingTimeText(), spokenValue: trip.movingTimeSpokenText())
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
