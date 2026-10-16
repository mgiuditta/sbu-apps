import SbuKit
import SwiftUI

/// The top of the detail: the subscription's sign and name, then its price as the screen's one figure.
struct DetailHeader: View {
    let subscription: Subscription

    @ScaledMetric(relativeTo: .title2) private var iconSide: CGFloat = 56

    var body: some View {
        VStack(alignment: .leading, spacing: SbuTheme.space4) {
            HStack(spacing: SbuTheme.space3) {
                Image(systemName: subscription.category?.symbol ?? Monogram.systemImage(for: subscription.name))
                    .font(SbuTheme.title2)
                    .fontWeight(.medium)
                    .imageScale(.medium)
                    // Not the accent: on this screen it belongs to the figure's full stop.
                    .foregroundStyle(SbuTheme.inkMuted)
                    .frame(width: iconSide, height: iconSide)
                    .background(SbuTheme.surfaceSunken, in: .rect(cornerRadius: SbuTheme.radiusLg))
                    .accessibilityHidden(true)
                Text(subscription.name)
                    .font(SbuTheme.title2)
                    .foregroundStyle(SbuTheme.ink)
                    .accessibilityAddTraits(.isHeader)
            }
            SbuStat("Prezzo", value: subscription.price(on: .now), format: .currency(code: subscription.currencyCode),
                    context: subscription.cycle.label)
        }
    }
}

#Preview("Light") {
    List { DetailHeader(subscription: .preview) }
        .modelContainer(.preview)
}

#Preview("Dark") {
    List { DetailHeader(subscription: .preview) }
        .modelContainer(.preview)
        .preferredColorScheme(.dark)
}
