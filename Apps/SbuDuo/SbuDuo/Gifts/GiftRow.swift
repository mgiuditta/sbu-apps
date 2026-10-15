import SbuKit
import SwiftUI

/// One gift: the idea, who it is for and when, the price on the right.
struct GiftRow: View {
    let gift: Gift
    let currencyCode: String

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: SbuTheme.space3) {
            VStack(alignment: .leading, spacing: SbuTheme.space1) {
                Text(gift.idea)
                    .font(SbuTheme.headline)
                    .foregroundStyle(SbuTheme.ink)
                Text(subtitle)
                    .font(SbuTheme.subheadline)
                    .foregroundStyle(SbuTheme.inkMuted)
            }
            Spacer()
            if let price = gift.price {
                Text(price, format: .currency(code: currencyCode))
                    .font(SbuTheme.subheadline.monospacedDigit())
                    .foregroundStyle(gift.isBought ? SbuTheme.inkMuted : SbuTheme.ink)
            }
        }
        .accessibilityElement(children: .combine)
    }

    private var subtitle: String {
        guard let occasion = gift.occasion else { return gift.person }
        return "\(gift.person) · \(occasion.formatted(.dateTime.day().month(.abbreviated)))"
    }
}
