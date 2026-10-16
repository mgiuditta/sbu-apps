import SbuKit
import SwiftUI

/// The top of the form, as the detail opens: the subscription's sign, its name, and the price with its currency.
struct FormHeader: View {
    @Binding var draft: SubscriptionDraft

    @ScaledMetric(relativeTo: .title2) private var iconSide: CGFloat = 56
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        HStack(spacing: SbuTheme.space3) {
            // At the accessibility sizes the fields get the whole width, as in the list rows.
            if !dynamicTypeSize.isAccessibilitySize {
                Image(systemName: draft.category?.symbol ?? Monogram.systemImage(for: draft.name))
                    .font(SbuTheme.title2)
                    .fontWeight(.medium)
                    .imageScale(.medium)
                    .foregroundStyle(SbuTheme.inkMuted)
                    .frame(width: iconSide, height: iconSide)
                    .background(SbuTheme.surfaceSunken, in: .rect(cornerRadius: SbuTheme.radiusLg))
                    .accessibilityHidden(true)
            }
            VStack(alignment: .leading, spacing: SbuTheme.space2) {
                TextField("Nome", text: $draft.name)
                    .font(SbuTheme.headline)
                    .accessibilityIdentifier("name")
                Divider()
                HStack(spacing: SbuTheme.space2) {
                    // The code, not the name: "EUR" leaves the price its room.
                    Menu {
                        Picker("Valuta", selection: $draft.currencyCode) {
                            ForEach(CurrencySection.currencies, id: \.self) { code in
                                Text(CurrencySection.name(of: code)).tag(code)
                            }
                        }
                    } label: {
                        Text(verbatim: draft.currencyCode)
                            .font(SbuTheme.body.monospacedDigit())
                            .padding(.horizontal, SbuTheme.space2)
                            .frame(minHeight: 44)
                            .background(SbuTheme.surfaceSunken, in: .rect(cornerRadius: SbuTheme.radiusSm))
                    }
                    .fixedSize()
                    .accessibilityLabel(Text("Valuta"))
                    .accessibilityValue(Text(verbatim: CurrencySection.name(of: draft.currencyCode)))
                    .accessibilityIdentifier("currency")
                    TextField("Prezzo", text: $draft.priceText, prompt: Text(verbatim: "0"))
                        .keyboardType(.decimalPad)
                        .font(SbuTheme.body.monospacedDigit())
                        .accessibilityIdentifier("price")
                }
            }
        }
        .padding(.vertical, SbuTheme.space1)
    }
}

#Preview("Light") {
    @Previewable @State var draft = SubscriptionDraft(currencyCode: "EUR")
    Form { FormHeader(draft: $draft) }
}

#Preview("Dark") {
    @Previewable @State var draft = SubscriptionDraft(currencyCode: "EUR")
    Form { FormHeader(draft: $draft) }
        .preferredColorScheme(.dark)
}
