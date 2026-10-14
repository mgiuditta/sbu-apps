import SbuKit
import SwiftUI

/// One currency in the rates list: its name, what one unit is worth in the main currency, and whose rate it is.
struct ExchangeRateRow: View {
    let code: String
    let settings: CurrencySettings

    var body: some View {
        LabeledContent {
            if let rate = settings.converter.convert(1, from: code, to: settings.mainCurrency) {
                VStack(alignment: .trailing) {
                    Text(rate, format: .currency(code: settings.mainCurrency).precision(.fractionLength(2...4)))
                        .monospacedDigit()
                    (settings.ownRates[code] == nil ? Text("BCE") : Text("Tuo"))
                        .font(.footnote)
                        .foregroundStyle(SbuTheme.inkMuted)
                }
            } else {
                Label("Manca il tasso", systemImage: "exclamationmark.triangle")
                    .foregroundStyle(SbuTheme.warning)
            }
        } label: {
            Text(CurrencySection.name(of: code))
            Text(code)
        }
    }
}
