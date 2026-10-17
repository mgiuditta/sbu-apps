import SbuKit
import SwiftUI

/// The figure zone of the home: the title and its cartiglio, then what your subscriptions cost over the period,
/// closed by the full stop, on the paper's grid.
struct SpendingFigure: View {
    let total: SpendingTotal
    let otherTotal: SpendingTotal
    let period: TotalPeriod
    /// The list, category or payment method the total is narrowed to, if any.
    var filterName: String?
    let currency: CurrencySettings
    let today: Date

    var body: some View {
        VStack(alignment: .leading, spacing: SbuTheme.gridCell) {
            // In whole cells, with a cell of padding and a cell of spacing: the figure starts on a grid line.
            SbuScreenTitle("Abbonamenti", cartiglio: Self.cartiglio(filterName: filterName, today: today))
                .wholeGridCells()
            SbuFigure(
                value: figure,
                fullStop: fullStop,
                context: Text(context)
            )
            notes
            if fullStop == .set {
                SbuFigureShareLink(SbuFigureCardImage(value: figure, word: period == .year ? "all'anno" : "al mese",
                                                      appName: "Sbu Subscriptions", accent: .subscriptions))
            }
        }
        .padding(.horizontal, SbuTheme.space4)
        .padding(.vertical, SbuTheme.gridCell)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var figure: String {
        total.amount.formatted(.currency(code: currency.mainCurrency))
    }

    /// Set once there is something counted and every price could be converted; waiting otherwise.
    private var fullStop: SbuFullStop.State {
        total.count > 0 && total.missingRates.isEmpty ? .set : .waiting
    }

    @ViewBuilder private var notes: some View {
        let missing = total.missingRates.sorted { $0.key < $1.key }
        if !missing.isEmpty || (total.isConverted && rateNote != nil) {
            VStack(alignment: .leading, spacing: SbuTheme.space1) {
                ForEach(missing, id: \.key) { code, count in
                    Label("Esclusi \(count) in \(code): manca il tasso", systemImage: "exclamationmark.triangle")
                        .foregroundStyle(SbuTheme.warning)
                }
                if total.isConverted, let rateNote {
                    Text(rateNote)
                        .foregroundStyle(SbuTheme.inkMuted)
                }
            }
            .font(SbuTheme.footnote)
            .fixedSize(horizontal: false, vertical: true)
        }
    }

    /// "Sbu · Abbonamenti · ottobre 2026", with the filter in between when the total is narrowed.
    static func cartiglio(filterName: String?, today: Date) -> String {
        let month = today.formatted(.dateTime.month(.wide).year())
        let parts = ["Sbu", String(localized: "Abbonamenti"), filterName, month].compactMap(\.self)
        return parts.joined(separator: " · ")
    }

    private var context: LocalizedStringKey {
        let other = otherTotal.amount.formatted(.currency(code: currency.mainCurrency))
        return period == .year
            ? "all'anno · \(other) al mese · ^[\(total.count) abbonamento](inflect: true)"
            : "al mese · \(other) all'anno · ^[\(total.count) abbonamento](inflect: true)"
    }

    private var rateNote: LocalizedStringKey? {
        if !currency.ownRates.isEmpty { return "Con i tassi inseriti da te" }
        guard let date = ExchangeRates.bundled.date else { return nil }
        return "Tassi BCE del \(date.formatted(.dateTime.day().month(.wide).year()))"
    }
}

#Preview("Light") {
    SpendingFigure(total: SpendingTotal([], per: .month, in: "EUR", converter: CurrencySettings().converter),
                   otherTotal: SpendingTotal([], per: .year, in: "EUR", converter: CurrencySettings().converter),
                   period: .month, currency: CurrencySettings(), today: .now)
        .sbuPaper(grid: true)
        .environment(\.sbuAccent, .subscriptions)
}

#Preview("Dark") {
    SpendingFigure(total: SpendingTotal([], per: .month, in: "EUR", converter: CurrencySettings().converter),
                   otherTotal: SpendingTotal([], per: .year, in: "EUR", converter: CurrencySettings().converter),
                   period: .month, currency: CurrencySettings(), today: .now)
        .sbuPaper(grid: true)
        .environment(\.sbuAccent, .subscriptions)
        .preferredColorScheme(.dark)
}
