import SbuKit
import SwiftData
import SwiftUI

/// The rate of every currency your subscriptions use besides the main one, and where it comes from.
struct ExchangeRatesView: View {
    let settings: CurrencySettings

    @Query private var subscriptions: [Subscription]

    var body: some View {
        Form {
            Section {
                if otherCurrencies.isEmpty {
                    Text("Tutti i tuoi abbonamenti sono in \(CurrencySection.name(of: settings.mainCurrency)).")
                        .foregroundStyle(SbuTheme.inkMuted)
                }
                ForEach(otherCurrencies, id: \.self) { code in
                    NavigationLink {
                        OwnRateView(code: code, settings: settings)
                    } label: {
                        ExchangeRateRow(code: code, settings: settings)
                    }
                }
            } footer: {
                Text(sourceNote)
            }
        }
        .navigationTitle("Tassi di cambio")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var otherCurrencies: [String] {
        Set(subscriptions.map(\.currencyCode))
            .subtracting([settings.mainCurrency])
            .sorted { CurrencySection.name(of: $0).localizedStandardCompare(CurrencySection.name(of: $1)) == .orderedAscending }
    }

    private var sourceNote: String {
        guard let date = ExchangeRates.bundled.date else {
            return String(localized: "Scrivi tu il tasso di ogni valuta.")
        }
        let day = date.formatted(.dateTime.day().month(.wide).year())
        return String(localized: "Tassi di riferimento BCE del \(day), inclusi nell'app: Sbu non va in rete. Tocca una valuta per scrivere il tasso del tuo estratto conto.")
    }
}

#Preview("Light") {
    NavigationStack { ExchangeRatesView(settings: CurrencySettings()) }
        .modelContainer(try! .subscriptions(inMemory: true))
}

#Preview("Dark") {
    NavigationStack { ExchangeRatesView(settings: CurrencySettings()) }
        .modelContainer(try! .subscriptions(inMemory: true))
        .preferredColorScheme(.dark)
}
