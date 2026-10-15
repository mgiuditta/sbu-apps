import SbuKit
import SwiftUI

/// What the vehicle costs: this month, this year, and fuel per kilometre or mile.
struct SpendingSection: View {
    let costs: CostSummary
    let distanceUnit: DistanceUnit
    let volumeUnit: VolumeUnit

    var body: some View {
        let now = Date.now
        Section("Spese") {
            ValueRow(title: "Questo mese", value: Money.text(costs.spent(inMonthOf: now)))
            ValueRow(title: "Quest'anno", value: Money.text(costs.spent(inYearOf: now)))
            if let perKm = costs.fuelCostPerKm {
                ValueRow(title: distanceUnit == .kilometres ? "Carburante al km" : "Carburante al miglio",
                         value: Money.perDistance(perKm, unit: distanceUnit))
            }
            if let price = costs.averagePricePerLitre {
                ValueRow(title: "Prezzo medio", value: Money.perVolume(price, unit: volumeUnit))
            }
        }
    }
}

#Preview("Light") {
    List {
        SpendingSection(costs: CostSummary(fills: [
            FillRecord(date: .now, odometerKm: 1_000, litres: 30, totalPrice: 54),
            FillRecord(date: .now, odometerKm: 1_600, litres: 37, totalPrice: 66),
        ], services: [], calendar: .current), distanceUnit: .kilometres, volumeUnit: .litres)
    }
}

#Preview("Dark") {
    List {
        SpendingSection(costs: CostSummary(fills: [
            FillRecord(date: .now, odometerKm: 1_000, litres: 30, totalPrice: 54),
            FillRecord(date: .now, odometerKm: 1_600, litres: 37, totalPrice: 66),
        ], services: [], calendar: .current), distanceUnit: .miles, volumeUnit: .usGallons)
    }
    .preferredColorScheme(.dark)
}
