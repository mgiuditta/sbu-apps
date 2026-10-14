import SbuKit
import SwiftUI

/// The one figure of the app: what your subscriptions cost over the period, closed by the full stop.
struct SpendingFigure: View {
    let total: SpendingTotal
    let otherTotal: SpendingTotal
    let period: TotalPeriod
    /// The list, category or payment method the total is narrowed to, if any.
    var filterName: String?
    let currency: CurrencySettings

    var body: some View {
        SbuToolField(caption, value: total.amount, format: .currency(code: currency.mainCurrency), context: context) {
            VStack(spacing: SbuTheme.space1) {
                ForEach(total.missingRates.sorted(by: { $0.key < $1.key }), id: \.key) { code, count in
                    Label("Esclusi \(count) in \(code): manca il tasso", systemImage: "exclamationmark.triangle")
                        .foregroundStyle(SbuTheme.warning)
                }
                if total.isConverted, let rateNote {
                    Text(rateNote)
                        .foregroundStyle(SbuTheme.inkMuted)
                }
            }
            .font(SbuTheme.footnote)
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)
        } pills: {
            EmptyView()
        }
    }

    private var caption: LocalizedStringKey {
        switch (period, filterName) {
        case (.year, nil): "Spendi all'anno"
        case (.month, nil): "Spendi al mese"
        case let (.year, name?): "Spendi all'anno · \(name)"
        case let (.month, name?): "Spendi al mese · \(name)"
        }
    }

    private var context: LocalizedStringKey {
        let other = otherTotal.amount.formatted(.currency(code: currency.mainCurrency))
        return period == .year
            ? "^[\(total.count) abbonamento](inflect: true) · \(other) al mese"
            : "^[\(total.count) abbonamento](inflect: true) · \(other) all'anno"
    }

    private var rateNote: LocalizedStringKey? {
        if !currency.ownRates.isEmpty { return "Con i tassi inseriti da te" }
        guard let date = ExchangeRates.bundled.date else { return nil }
        return "Tassi BCE del \(date.formatted(.dateTime.day().month(.wide).year()))"
    }
}
