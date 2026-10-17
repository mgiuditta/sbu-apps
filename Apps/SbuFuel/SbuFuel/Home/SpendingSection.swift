import SbuKit
import SwiftUI

/// What the vehicle costs: this month, this year, and fuel per kilometre or mile.
struct SpendingSection: View {
    let costs: CostSummary
    let distanceUnit: DistanceUnit
    let volumeUnit: VolumeUnit

    var body: some View {
        CardSection(title: "Spese") {
            SbuListCard(values) { value in
                ValueRow(value)
            }
        }
    }

    private var values: [OverviewValue] {
        let now = Date.now
        var values = [
            OverviewValue(id: "month", title: "Questo mese", value: Money.text(costs.spent(inMonthOf: now))),
            OverviewValue(id: "year", title: "Quest'anno", value: Money.text(costs.spent(inYearOf: now))),
        ]
        if let perKm = costs.fuelCostPerKm {
            values.append(OverviewValue(id: "perDistance", title: distanceUnit == .kilometres ? "Carburante al km" : "Carburante al miglio",
                                        value: Money.perDistance(perKm, unit: distanceUnit)))
        }
        if let price = costs.averagePricePerLitre {
            values.append(OverviewValue(id: "price", title: "Prezzo medio", value: Money.perVolume(price, unit: volumeUnit)))
        }
        return values
    }
}

#Preview("Light") {
    SpendingSection(costs: CostSummary(fills: [
        FillRecord(date: .now, odometerKm: 1_000, litres: 30, totalPrice: 54),
        FillRecord(date: .now, odometerKm: 1_600, litres: 37, totalPrice: 66),
    ], services: [], calendar: .current), distanceUnit: .kilometres, volumeUnit: .litres)
    .padding(SbuTheme.space4)
    .frame(maxHeight: .infinity, alignment: .top)
    .sbuPaper(grid: false)
}

#Preview("Dark") {
    SpendingSection(costs: CostSummary(fills: [
        FillRecord(date: .now, odometerKm: 1_000, litres: 30, totalPrice: 54),
        FillRecord(date: .now, odometerKm: 1_600, litres: 37, totalPrice: 66),
    ], services: [], calendar: .current), distanceUnit: .miles, volumeUnit: .usGallons)
    .padding(SbuTheme.space4)
    .frame(maxHeight: .infinity, alignment: .top)
    .sbuPaper(grid: false)
    .preferredColorScheme(.dark)
}
