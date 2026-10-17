import SbuKit
import SwiftUI

/// The one figure of the app: the average consumption of the selected vehicle, closed by the full stop.
/// Until the second full tank there is nothing to count: a waiting "0" and what to do next.
struct ConsumptionFigure: View {
    let consumption: ConsumptionCalculator
    let hasFuelUps: Bool
    let unit: ConsumptionUnit
    let distanceUnit: DistanceUnit

    var body: some View {
        if let average = consumption.averageKmPerLitre {
            // The unit goes in the context line: beside the figure "L/100 km" shrank the number to a third.
            SbuFigure(
                value: unit.formatted(kmPerLitre: average),
                fullStop: .set,
                context: Text(verbatim: context),
                accessibilityLabel: Text("Consumo medio, \(unit.spoken(kmPerLitre: average)), \(stretch)")
            )
            .accessibilityIdentifier("figure")
        } else {
            SbuEmpty(sentence: hasFuelUps ? "Fai il prossimo pieno per vedere il consumo." : "Registra un pieno per iniziare.")
        }
    }

    /// "1.600 km" from the first full tank to the last.
    private var distance: String {
        distanceUnit.formatted(km: consumption.segments.reduce(0) { $0 + $1.distanceKm })
    }

    /// "Da pieno a pieno, su 1.600 km".
    private var stretch: String {
        String(localized: "Da pieno a pieno, su \(distance)")
    }

    /// "L/100 km · Da pieno a pieno, su 1.600 km".
    private var context: String {
        [unit.symbol, stretch].joined(separator: " · ")
    }
}

#Preview("Light") {
    ConsumptionFigure(consumption: ConsumptionCalculator([
        FillRecord(date: .now.addingTimeInterval(-86_400 * 14), odometerKm: 1_000, litres: 30),
        FillRecord(date: .now, odometerKm: 1_600, litres: 37),
    ]), hasFuelUps: true, unit: .litresPer100Km, distanceUnit: .kilometres)
    .padding(SbuTheme.space4)
    .sbuPaper(grid: true)
    .environment(\.sbuAccent, .fuel)
}

#Preview("Dark") {
    ConsumptionFigure(consumption: ConsumptionCalculator([]), hasFuelUps: true, unit: .mpgUS, distanceUnit: .miles)
        .padding(SbuTheme.space4)
        .sbuPaper(grid: true)
        .environment(\.sbuAccent, .fuel)
        .preferredColorScheme(.dark)
}
