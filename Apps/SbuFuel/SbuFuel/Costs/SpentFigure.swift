import SbuKit
import SwiftUI

/// The one figure of Spese e grafici: what the vehicle cost over the range, in whole units, with
/// fuel and services to the cent under it.
struct SpentFigure: View {
    let costs: CostSummary
    var locale = Locale.current

    var body: some View {
        let context = Text("Speso · carburante \(Money.text(costs.fuelTotal, locale: locale)) · interventi \(Money.text(costs.serviceTotal, locale: locale))")
        SbuFigure(
            value: costs.total.formatted(.currency(code: Money.currencyCode(for: locale)).precision(.fractionLength(0)).locale(locale)),
            fullStop: costs.total > 0 ? .set : .waiting,
            context: context,
            accessibilityLabel: Text("Speso \(Money.text(costs.total, locale: locale)): carburante \(Money.text(costs.fuelTotal, locale: locale)), interventi \(Money.text(costs.serviceTotal, locale: locale))")
        )
        .frame(maxWidth: .infinity, alignment: .leading)
        // Plain paper, not the grid: the figure sits above List rows. It still gives the figure its grid space.
        .sbuPaper(grid: false)
        .accessibilityIdentifier("spent")
    }
}

#Preview("Light") {
    SpentFigure(costs: CostSummary(fills: [
        FillRecord(date: .now, odometerKm: 1_000, litres: 30, totalPrice: 54),
        FillRecord(date: .now, odometerKm: 1_600, litres: 37, totalPrice: 66.4),
    ], services: [ServiceCost(date: .now, cost: 89)], calendar: .current))
    .padding(SbuTheme.space4)
    .frame(maxHeight: .infinity, alignment: .top)
    .environment(\.sbuAccent, .fuel)
}

#Preview("Dark") {
    SpentFigure(costs: CostSummary(fills: [], services: [], calendar: .current))
        .padding(SbuTheme.space4)
        .frame(maxHeight: .infinity, alignment: .top)
        .environment(\.sbuAccent, .fuel)
        .preferredColorScheme(.dark)
}
