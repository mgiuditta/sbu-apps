import SbuKit
import SwiftUI

/// The top of the detail: the subscription's sign and name, then its price as the screen's one figure,
/// which gives way to "Pagato" when you mark a payment paid.
struct DetailHeader: View {
    let subscription: Subscription
    @Binding var isClosing: Bool

    @ScaledMetric(relativeTo: .title2) private var iconSide: CGFloat = 56

    var body: some View {
        // The name in whole cells and a cell of spacing: the figure starts on a grid line of the header's paper.
        VStack(alignment: .leading, spacing: SbuTheme.gridCell) {
            HStack(spacing: SbuTheme.space3) {
                Image(systemName: subscription.category?.symbol ?? Monogram.systemImage(for: subscription.name))
                    .font(SbuTheme.title2)
                    .fontWeight(.medium)
                    .imageScale(.medium)
                    .foregroundStyle(SbuTheme.inkMuted)
                    .frame(width: iconSide, height: iconSide)
                    .background(SbuTheme.surfaceSunken, in: .rect(cornerRadius: SbuTheme.radiusCard))
                    .accessibilityHidden(true)
                Text(subscription.name)
                    .font(SbuTheme.title2)
                    .foregroundStyle(SbuTheme.ink)
                    .accessibilityAddTraits(.isHeader)
            }
            .wholeGridCells()
            SbuFigure(
                value: subscription.price(on: .now).formatted(.currency(code: subscription.currencyCode)),
                context: Text(subscription.cycle.label)
            )
            .sbuClosure($isClosing, word: "Pagato")
        }
        // In line with the rows' text below, and clear of the row's edge.
        .padding(.horizontal, SbuTheme.space4)
        .frame(maxWidth: .infinity, alignment: .leading)
        // Plain paper, no grid: the header is a list row; it gives the figure the space it snaps in.
        .sbuPaper(grid: false)
    }
}

#Preview("Light") {
    List { DetailHeader(subscription: .preview, isClosing: .constant(false)) }
        .modelContainer(.preview)
        .environment(\.sbuAccent, .subscriptions)
}

#Preview("Dark") {
    List { DetailHeader(subscription: .preview, isClosing: .constant(false)) }
        .modelContainer(.preview)
        .environment(\.sbuAccent, .subscriptions)
        .preferredColorScheme(.dark)
}
