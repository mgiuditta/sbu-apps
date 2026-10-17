import Charts
import SbuKit
import SwiftUI

/// Fuel and services per month, stacked. Fuel in ink, services in inkMuted, named in the legend.
struct MonthlySpendChart: View {
    let months: [MonthSpend]

    @State private var selectedDate: Date?
    @ScaledMetric(relativeTo: .body) private var height = 180

    private var fuelName: String { String(localized: "Carburante") }
    private var serviceName: String { String(localized: "Interventi") }

    var body: some View {
        if months.allSatisfy({ $0.total == 0 }) {
            ChartPlaceholder(text: "Nessuna spesa nel periodo.")
        } else {
            Chart {
                ForEach(months) { month in
                    BarMark(x: .value("Mese", month.month, unit: .month), y: .value("Spesa", double(month.fuel)))
                        .foregroundStyle(by: .value("Voce", fuelName))
                        .accessibilityLabel(month.month.formatted(.dateTime.month(.wide).year()))
                        .accessibilityValue("\(fuelName) \(Money.text(month.fuel)), \(serviceName) \(Money.text(month.service))")
                    BarMark(x: .value("Mese", month.month, unit: .month), y: .value("Spesa", double(month.service)))
                        .foregroundStyle(by: .value("Voce", serviceName))
                        .accessibilityHidden(true)
                }
                if let selected {
                    RuleMark(x: .value("Mese", selected.month, unit: .month))
                        .foregroundStyle(SbuTheme.line)
                        .zIndex(-1)
                        .annotation(position: .top, overflowResolution: .init(x: .fit(to: .chart), y: .disabled)) {
                            ChartCallout(value: Money.text(selected.total), date: selected.month.formatted(.dateTime.month(.wide).year()))
                        }
                }
            }
            .chartForegroundStyleScale([fuelName: SbuTheme.ink, serviceName: SbuTheme.inkMuted])
            .chartLegend(position: .bottom, alignment: .leading)
            .chartXSelection(value: $selectedDate)
            // Axis labels stop growing at the largest standard size: beyond it the months turned into ellipses.
            // The values stay readable under your finger and in VoiceOver at every size.
            .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
            .frame(height: height)
            .padding(.vertical, SbuTheme.space2)
            .listRowBackground(SbuTheme.surfaceRaised)
        }
    }

    private var selected: MonthSpend? {
        guard let selectedDate else { return nil }
        return months.first { Calendar.current.isDate($0.month, equalTo: selectedDate, toGranularity: .month) }
    }

    private func double(_ amount: Decimal) -> Double {
        NSDecimalNumber(decimal: amount).doubleValue
    }
}

#Preview("Light") {
    List {
        MonthlySpendChart(months: [
            MonthSpend(month: .now.addingTimeInterval(-86_400 * 62), fuel: 120, service: 0),
            MonthSpend(month: .now.addingTimeInterval(-86_400 * 31), fuel: 98, service: 89),
            MonthSpend(month: .now, fuel: 134, service: 0),
        ])
    }
}

#Preview("Dark") {
    List {
        MonthlySpendChart(months: [])
    }
    .preferredColorScheme(.dark)
}
