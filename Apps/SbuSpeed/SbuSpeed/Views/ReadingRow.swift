import SbuKit
import SwiftUI

/// One row of the readings card: the label, and the value secondary in `inkMuted` with tabular figures.
/// At accessibility text sizes the value goes under the label, so neither is cut.
struct ReadingRow: View {
    let reading: SpeedReading

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    private var layout: AnyLayout {
        dynamicTypeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(alignment: .leading, spacing: SbuTheme.space1))
            : AnyLayout(HStackLayout(alignment: .firstTextBaseline, spacing: SbuTheme.space3))
    }

    var body: some View {
        layout {
            Text(reading.label)

            if !dynamicTypeSize.isAccessibilitySize {
                Spacer(minLength: 0)
            }

            Text(verbatim: reading.value)
                .monospacedDigit()
                .foregroundStyle(SbuTheme.inkMuted)
                .contentTransition(.numericText())
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(reading.spokenLabel ?? reading.label))
        .accessibilityValue(Text(verbatim: reading.spokenValue ?? reading.value))
    }
}

#Preview("Light") {
    ReadingsCard(readings: ReadingRow.previewReadings)
        .padding(SbuTheme.space4)
        .frame(maxHeight: .infinity, alignment: .top)
        .sbuPaper()
}

#Preview("Dark") {
    ReadingsCard(readings: ReadingRow.previewReadings)
        .padding(SbuTheme.space4)
        .frame(maxHeight: .infinity, alignment: .top)
        .sbuPaper()
        .preferredColorScheme(.dark)
}

extension ReadingRow {
    static var previewReadings: [SpeedReading] {
        SpeedReading.readings(
            trip: Trip(maxSpeed: 24.2, distance: 12_400, movingTime: 970),
            navigation: NavigationReading(altitude: 122, course: 247),
            unit: .kilometersPerHour
        )
    }
}
