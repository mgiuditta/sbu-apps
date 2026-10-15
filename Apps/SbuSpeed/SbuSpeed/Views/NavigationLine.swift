import SbuKit
import SwiftUI

/// Altitude and course under the figure, secondary in `inkMuted` like the trip: side by side,
/// one under the other at accessibility text sizes. With knots the course is COG, as on a chart plotter.
struct NavigationLine: View {
    let reading: NavigationReading
    let unit: SpeedUnit

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    private var layout: AnyLayout {
        dynamicTypeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(spacing: SbuTheme.space4))
            : AnyLayout(HStackLayout(alignment: .top, spacing: SbuTheme.space4))
    }

    var body: some View {
        layout {
            TripValue(
                label: "Altitudine",
                value: reading.altitudeText(unit: unit),
                spokenValue: reading.altitudeSpokenText(unit: unit)
            )

            TripValue(
                label: unit == .knots ? "COG" : "Rotta",
                spokenLabel: unit == .knots ? "Rotta sul fondo" : nil,
                value: reading.courseText(),
                spokenValue: reading.courseSpokenText()
            )
        }
    }
}

#Preview("Light") {
    NavigationLinePreview()
}

#Preview("Dark") {
    NavigationLinePreview()
        .preferredColorScheme(.dark)
}

private struct NavigationLinePreview: View {
    var body: some View {
        VStack(spacing: SbuTheme.space6) {
            NavigationLine(reading: NavigationReading(altitude: 122, course: 247), unit: .kilometersPerHour)
            NavigationLine(reading: NavigationReading(altitude: 3, course: 12), unit: .knots)
            NavigationLine(reading: NavigationReading(), unit: .milesPerHour)
        }
        .padding(SbuTheme.space4)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(SbuTheme.surface)
    }
}
