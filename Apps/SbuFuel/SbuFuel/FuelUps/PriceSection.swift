import SbuKit
import SwiftUI

/// Quantity and price of a fuel-up: type the total or the price per unit, the other is worked out.
struct PriceSection: View {
    @Binding var draft: FuelUpDraft
    let tankLitres: Double?

    private var currencySymbol: String {
        draft.locale.currencySymbol ?? Money.currencyCode(for: draft.locale)
    }

    var body: some View {
        Section {
            NumberField(title: "Quantità", text: $draft.quantityText, unit: draft.volumeUnit.symbol, identifier: "quantity")
            Picker("Prezzo", selection: $draft.priceKind) {
                Text("Totale").tag(FuelUpDraft.PriceKind.total)
                Text(draft.volumeUnit == .litres ? "Al litro" : "Al gallone").tag(FuelUpDraft.PriceKind.perUnit)
            }
            .pickerStyle(.segmented)
            .accessibilityIdentifier("priceKind")
            NumberField(title: draft.priceKind == .total ? "Importo" : "Prezzo", text: $draft.priceText, unit: currencySymbol, identifier: "price")
        } footer: {
            VStack(alignment: .leading, spacing: SbuTheme.space1) {
                if let tankLitres, let litres = draft.litres, litres > tankLitres * 1.05 {
                    ProblemLabel(text: Text("Più di quanto tiene il serbatoio (\(draft.volumeUnit.formatted(litres: tankLitres))): controlla la quantità."), tone: .warning)
                }
                if let worked {
                    Text(worked)
                }
            }
        }
    }

    /// The other half of the price, once there is enough to work it out.
    private var worked: LocalizedStringKey? {
        guard draft.quantity != nil, !draft.priceText.isEmpty else { return nil }
        switch draft.priceKind {
        case .total:
            guard let unitPrice = draft.unitPrice else { return nil }
            return "Prezzo: \(Money.perUnit(unitPrice, symbol: draft.volumeUnit.symbol, locale: draft.locale))"
        case .perUnit:
            return "Totale: \(Money.text(draft.totalPrice, locale: draft.locale))"
        }
    }
}

#Preview("Light") {
    @Previewable @State var draft = FuelUpDraft(distanceUnit: .kilometres, volumeUnit: .litres)
    Form {
        PriceSection(draft: $draft, tankLitres: 40)
    }
}

#Preview("Dark") {
    @Previewable @State var draft = FuelUpDraft(distanceUnit: .miles, volumeUnit: .usGallons)
    Form {
        PriceSection(draft: $draft, tankLitres: nil)
    }
    .preferredColorScheme(.dark)
}
