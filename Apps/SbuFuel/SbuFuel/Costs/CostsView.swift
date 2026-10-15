import SbuKit
import SwiftData
import SwiftUI

/// What the vehicle cost over a range, with the consumption, monthly spending and price charts.
struct CostsView: View {
    let vehicle: Vehicle
    let units: UnitSettings

    @AppStorage("costs.range") private var range = ChartRange.twelveMonths

    var body: some View {
        let now = Date.now
        let calendar = Calendar.current
        let start = range.start(now: now, calendar: calendar)
        let fills = vehicle.fillRecords.filter { range.contains($0.date, now: now, calendar: calendar) }
        let services = (vehicle.services ?? []).filter { range.contains($0.date, now: now, calendar: calendar) }
            .map { ServiceCost(date: $0.date, cost: $0.cost) }
        let costs = CostSummary(fills: fills, services: services, calendar: calendar)
        // Segments are worked out on the whole log, so one that ends in the range keeps its opening tank.
        let segments = ConsumptionCalculator(vehicle.fillRecords).segments.filter { range.contains($0.endDate, now: now, calendar: calendar) }
        let months = costs.months(from: start, to: now)
        List {
            Section {
                Picker("Periodo", selection: $range) {
                    ForEach(ChartRange.allCases) { range in
                        Text(range.name).tag(range)
                    }
                }
                .pickerStyle(.segmented)
                .accessibilityIdentifier("range")
            }
            .listRowInsets(EdgeInsets())
            .listRowBackground(Color.clear)
            Section {
                SbuStat("Speso", value: costs.total, format: .currency(code: Money.currencyCode(for: .current)),
                        context: "Carburante \(Money.text(costs.fuelTotal)) · interventi \(Money.text(costs.serviceTotal))")
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
            }
            Section {
                if let perKm = costs.fuelCostPerKm {
                    ValueRow(title: vehicle.odometerUnit == .kilometres ? "Carburante al km" : "Carburante al miglio",
                             value: Money.perDistance(perKm, unit: vehicle.odometerUnit))
                }
                if let price = costs.averagePricePerLitre {
                    ValueRow(title: "Prezzo medio", value: Money.perVolume(price, unit: units.volume))
                }
                if !months.isEmpty {
                    ValueRow(title: "In media al mese", value: Money.text(costs.total / Decimal(months.count)))
                }
            }
            Section("Consumo") {
                ConsumptionChart(segments: segments, unit: units.consumption)
            }
            Section("Spesa al mese") {
                MonthlySpendChart(months: months)
            }
            Section(units.volume == .litres ? "Prezzo al litro" : "Prezzo al gallone") {
                PriceChart(fills: fills, volumeUnit: units.volume)
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(SbuTheme.surface)
        .navigationTitle("Spese e grafici")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview("Light") {
    CostsPreview()
        .modelContainer(.preview)
}

#Preview("Dark") {
    CostsPreview()
        .modelContainer(.preview)
        .preferredColorScheme(.dark)
}

private struct CostsPreview: View {
    @Query private var vehicles: [Vehicle]

    var body: some View {
        NavigationStack {
            if let vehicle = vehicles.first {
                CostsView(vehicle: vehicle, units: UnitSettings())
            }
        }
        .tint(SbuTheme.accentFuel)
    }
}
