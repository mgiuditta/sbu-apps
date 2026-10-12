import SbuKit
import SwiftUI

/// The moon's age since the last new moon and its distance from the Earth, for the date shown.
struct MoonDetailsView: View {
    let age: Duration
    let distance: Measurement<UnitLength>

    var body: some View {
        VStack(spacing: SbuTheme.space2) {
            MoonFactRow("Età della luna", value: Text(age, format: MoonDetailFormat.age))
            MoonFactRow("Distanza dalla Terra", value: Text(distance, format: MoonDetailFormat.distance))
        }
    }
}

#Preview("Light") {
    MoonDetailsPreview()
}

#Preview("Dark") {
    MoonDetailsPreview()
        .preferredColorScheme(.dark)
}

private struct MoonDetailsPreview: View {
    private let reading = MoonReading(date: .now, calendar: .current)

    var body: some View {
        MoonDetailsView(age: reading.age, distance: reading.distance)
            .padding(SbuTheme.space4)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(SbuTheme.surface)
    }
}
