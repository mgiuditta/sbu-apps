import SwiftUI

/// Type the rate from your bank statement for one currency, or go back to the ECB rate.
struct OwnRateView: View {
    let code: String
    let settings: CurrencySettings

    @State private var draft: Decimal?

    init(code: String, settings: CurrencySettings) {
        self.code = code
        self.settings = settings
        _draft = State(initialValue: settings.converter.convert(1, from: code, to: settings.mainCurrency))
    }

    var body: some View {
        Form {
            Section {
                LabeledContent("1 \(code) =") {
                    HStack {
                        TextField("Tasso", value: $draft, format: .number.precision(.fractionLength(0...6)))
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .accessibilityIdentifier("ownRate")
                        Text(settings.mainCurrency)
                            .accessibilityHidden(true)
                    }
                }
            } footer: {
                Text("Quanto vale 1 \(CurrencySection.name(of: code)) in \(CurrencySection.name(of: settings.mainCurrency)).")
            }

            if settings.ownRates[code] != nil, let ecbRate {
                Section {
                    Button("Usa il tasso BCE") { draft = ecbRate }
                }
            }
        }
        .navigationTitle(CurrencySection.name(of: code))
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: draft) {
            save()
        }
    }

    private var ecbRate: Decimal? {
        CurrencyConverter(table: .bundled).convert(1, from: code, to: settings.mainCurrency)
    }

    /// A rate equal to the ECB one is no rate of your own, so typing it back is the same as resetting.
    private func save() {
        guard let draft, draft > 0 else { return }
        if draft == ecbRate {
            settings.ownRates[code] = nil
        } else {
            settings.ownRates[code] = OwnRate(value: draft, currencyCode: settings.mainCurrency, date: .now)
        }
    }
}

#Preview("Light") {
    NavigationStack { OwnRateView(code: "USD", settings: CurrencySettings()) }
}

#Preview("Dark") {
    NavigationStack { OwnRateView(code: "USD", settings: CurrencySettings()) }
        .preferredColorScheme(.dark)
}
