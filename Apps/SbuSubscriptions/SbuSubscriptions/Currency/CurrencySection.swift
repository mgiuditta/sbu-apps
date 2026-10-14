import SwiftData
import SwiftUI

/// Settings → the main currency of the totals, and the rates that convert every other one.
struct CurrencySection: View {
    @Bindable var settings: CurrencySettings

    var body: some View {
        Section {
            Picker("Valuta principale", selection: $settings.mainCurrency) {
                ForEach(Self.currencies, id: \.self) { code in
                    Text(Self.name(of: code)).tag(code)
                }
            }
            .pickerStyle(.navigationLink)

            NavigationLink("Tassi di cambio") {
                ExchangeRatesView(settings: settings)
            }
        } footer: {
            Text("I totali sono in questa valuta. Gli abbonamenti in altre valute si convertono con i tassi BCE inclusi nell'app, o con i tuoi.")
        }
    }

    static func name(of code: String) -> String {
        // Only the first letter: "US dollar", not localizedCapitalized's "Us Dollar".
        guard let name = Locale.current.localizedString(forCurrencyCode: code), let first = name.first else { return code }
        return first.uppercased() + name.dropFirst()
    }

    static let currencies = Locale.commonISOCurrencyCodes.sorted {
        name(of: $0).localizedStandardCompare(name(of: $1)) == .orderedAscending
    }
}

#Preview("Light") {
    NavigationStack {
        Form { CurrencySection(settings: CurrencySettings()) }
    }
    .modelContainer(try! .subscriptions(inMemory: true))
}

#Preview("Dark") {
    NavigationStack {
        Form { CurrencySection(settings: CurrencySettings()) }
    }
    .modelContainer(try! .subscriptions(inMemory: true))
    .preferredColorScheme(.dark)
}
