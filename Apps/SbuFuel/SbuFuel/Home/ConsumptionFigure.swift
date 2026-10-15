import SbuKit
import SwiftUI

/// The one figure of the app: the average consumption of the selected vehicle, closed by the full stop.
/// Until the second full tank there is no figure, only what to do next.
struct ConsumptionFigure: View {
    let consumption: ConsumptionCalculator
    let hasFuelUps: Bool
    let unit: ConsumptionUnit
    let distanceUnit: DistanceUnit

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        if let average = consumption.averageKmPerLitre {
            SbuToolField(
                "Consumo medio",
                value: unit.value(fromKmPerLitre: average),
                format: .number.precision(.fractionLength(1)),
                // At the accessibility sizes "L/100 km" broke over three lines beside the figure: there it moves into the context line.
                unit: dynamicTypeSize.isAccessibilitySize ? nil : "\u{2009}" + unit.symbol,
                context: context
            ) {
                EmptyView()
            } pills: {
                EmptyView()
            }
            .accessibilityIdentifier("figure")
        } else {
            SbuToolField("Consumo medio", context: hasFuelUps ? "Fai il prossimo pieno per vedere il consumo." : "Registra un pieno per iniziare.") {
                EmptyView()
            } pills: {
                EmptyView()
            }
            .accessibilityIdentifier("figure")
        }
    }

    private var context: LocalizedStringKey {
        let distance = distanceUnit.formatted(km: consumption.segments.reduce(0) { $0 + $1.distanceKm })
        let line = String(localized: "Da pieno a pieno, su \(distance)")
        return dynamicTypeSize.isAccessibilitySize ? "\(unit.symbol) · \(line)" : "\(line)"
    }
}

#Preview("Light") {
    ConsumptionFigure(consumption: ConsumptionCalculator([
        FillRecord(date: .now.addingTimeInterval(-86_400 * 14), odometerKm: 1_000, litres: 30),
        FillRecord(date: .now, odometerKm: 1_600, litres: 37),
    ]), hasFuelUps: true, unit: .litresPer100Km, distanceUnit: .kilometres)
    .background(SbuTheme.surface)
    .tint(SbuTheme.accentFuel)
}

#Preview("Dark") {
    ConsumptionFigure(consumption: ConsumptionCalculator([]), hasFuelUps: true, unit: .mpgUS, distanceUnit: .miles)
        .background(SbuTheme.surface)
        .tint(SbuTheme.accentFuel)
        .preferredColorScheme(.dark)
}
