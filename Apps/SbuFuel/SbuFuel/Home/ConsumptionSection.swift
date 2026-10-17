import SbuKit
import SwiftUI

/// The last, best and worst full-to-full segments under the average.
struct ConsumptionSection: View {
    let consumption: ConsumptionCalculator
    let unit: ConsumptionUnit

    var body: some View {
        let values = values
        if !values.isEmpty {
            CardSection(title: "Consumo") {
                SbuListCard(values) { value in
                    ValueRow(value)
                }
            }
        }
    }

    private var values: [OverviewValue] {
        var values: [OverviewValue] = []
        if let last = consumption.last {
            values.append(value(id: "last", title: "Ultimo pieno", last))
        }
        if consumption.segments.count > 1, let best = consumption.best, let worst = consumption.worst {
            values.append(value(id: "best", title: "Il migliore", best))
            values.append(value(id: "worst", title: "Il peggiore", worst))
        }
        return values
    }

    private func value(id: String, title: LocalizedStringKey, _ segment: ConsumptionSegment) -> OverviewValue {
        OverviewValue(id: id, title: title, value: unit.formatted(kmPerLitre: segment.kmPerLitre) + "\u{00A0}" + unit.symbol,
                      spokenValue: unit.spoken(kmPerLitre: segment.kmPerLitre))
    }
}

#Preview("Light") {
    ConsumptionSection(consumption: ConsumptionCalculator([
        FillRecord(date: .now, odometerKm: 1_000, litres: 30),
        FillRecord(date: .now, odometerKm: 1_600, litres: 37),
        FillRecord(date: .now, odometerKm: 2_100, litres: 33),
    ]), unit: .litresPer100Km)
    .padding(SbuTheme.space4)
    .frame(maxHeight: .infinity, alignment: .top)
    .sbuPaper(grid: false)
}

#Preview("Dark") {
    ConsumptionSection(consumption: ConsumptionCalculator([
        FillRecord(date: .now, odometerKm: 1_000, litres: 30),
        FillRecord(date: .now, odometerKm: 1_600, litres: 37),
    ]), unit: .mpgUS)
    .padding(SbuTheme.space4)
    .frame(maxHeight: .infinity, alignment: .top)
    .sbuPaper(grid: false)
    .preferredColorScheme(.dark)
}
