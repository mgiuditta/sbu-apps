import SbuKit
import SwiftUI

/// A saved trip in the list: when it started, then distance and time, then top and average speed.
struct TripRow: View {
    let trip: TripRecord
    let unit: SpeedUnit

    private var distance: String { unit.distanceText(meters: trip.distance) }
    private var top: String { unit.speedText(metersPerSecond: trip.maxSpeed) }
    private var average: String { unit.speedText(metersPerSecond: trip.averageSpeed) }

    var body: some View {
        VStack(alignment: .leading, spacing: SbuTheme.space1) {
            Text(trip.startedAt, format: .dateTime.day().month().year().hour().minute())
                .font(SbuTheme.headline)
                .foregroundStyle(SbuTheme.ink)

            Text(verbatim: "\(distance) · \(Trip.clockText(trip.movingDuration))")
                .font(SbuTheme.subheadline.monospacedDigit())
                .foregroundStyle(SbuTheme.inkMuted)

            Text("Massima \(top) · Media \(average)")
                .font(SbuTheme.subheadline.monospacedDigit())
                .foregroundStyle(SbuTheme.inkMuted)
        }
        .padding(.vertical, SbuTheme.space1)
        // The clock reads badly aloud: VoiceOver gets the time in words.
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(trip.startedAt, format: .dateTime.day().month(.wide).year().hour().minute()))
        .accessibilityValue(Text("\(distance), \(Trip.spokenText(trip.movingDuration)), massima \(top), media \(average)"))
    }
}

#Preview("Light") {
    TripRowPreview()
}

#Preview("Dark") {
    TripRowPreview()
        .preferredColorScheme(.dark)
}

private struct TripRowPreview: View {
    var body: some View {
        List {
            ForEach(TripLogFile.demo(now: .now).trips) { trip in
                TripRow(trip: trip, unit: .kilometersPerHour)
            }
        }
        .listStyle(.insetGrouped)
    }
}
