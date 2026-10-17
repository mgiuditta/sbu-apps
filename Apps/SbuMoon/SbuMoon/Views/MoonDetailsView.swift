import SbuKit
import SwiftUI

/// The moon's age since the last new moon and its distance from the Earth, for the date shown, in a
/// card on the paper.
struct MoonDetailsView: View {
    let age: Duration
    let distance: Measurement<UnitLength>

    private var facts: [MoonFact] {
        [
            MoonFact(id: "age", label: "Età della luna", value: Text(age, format: MoonDetailFormat.age)),
            MoonFact(id: "distance", label: "Distanza dalla Terra", value: Text(distance, format: MoonDetailFormat.distance)),
        ]
    }

    var body: some View {
        SbuListCard(facts) { fact in
            MoonFactRow(fact)
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
            .sbuPaper(grid: true)
    }
}
