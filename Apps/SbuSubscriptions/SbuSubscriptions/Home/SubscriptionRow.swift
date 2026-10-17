import SbuKit
import SwiftUI

/// One subscription on the home: the row mark (filled when it renews within the week), its name, when it renews
/// in words and the day in the cartiglio's face, then the price and cycle.
struct SubscriptionRow: View {
    let subscription: Subscription
    let today: Date

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        let renewal = RenewalStatus(
            status: subscription.status,
            trialEnd: subscription.isInTrial(on: today) ? subscription.trialEndDate : nil,
            nextPayment: subscription.nextPayment(after: today),
            today: today,
            calendar: .current
        )
        // Side by side, the text wrapping first; stacked at the accessibility sizes, the price under the name.
        let isStacked = dynamicTypeSize.isAccessibilitySize
        let layout = isStacked
            ? AnyLayout(VStackLayout(alignment: .leading, spacing: SbuTheme.space1))
            : AnyLayout(HStackLayout(spacing: SbuTheme.space2))
        layout {
            HStack(alignment: .firstTextBaseline, spacing: SbuTheme.space3) {
                SbuRowMark(filled: renewal.isWithinWeek)
                VStack(alignment: .leading, spacing: SbuTheme.space1) {
                    Text(subscription.name)
                        .font(SbuTheme.headline)
                        .foregroundStyle(SbuTheme.ink)
                    Text(word(renewal))
                        .font(SbuTheme.subheadline)
                        .foregroundStyle(SbuTheme.inkMuted)
                    if let day = renewal.day {
                        Text(day, format: .dateTime.weekday(.abbreviated).day().month(.abbreviated))
                            .font(.sbuCartiglio)
                            .foregroundStyle(SbuTheme.inkMuted)
                    }
                }
                .alignmentGuide(.listRowSeparatorLeading) { $0[.leading] }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            VStack(alignment: isStacked ? .leading : .trailing, spacing: 0) {
                Text(subscription.price, format: .currency(code: subscription.currencyCode))
                    .font(SbuTheme.statSmall)
                    .foregroundStyle(SbuTheme.ink)
                Text(subscription.cycle.label)
                    .font(SbuTheme.footnote)
                    .foregroundStyle(SbuTheme.inkMuted)
            }
            // The price keeps its width; the name wraps instead.
            .fixedSize(horizontal: !isStacked, vertical: false)
        }
        .listRowInsets(EdgeInsets(top: SbuTheme.space3, leading: SbuTheme.space4, bottom: SbuTheme.space3, trailing: SbuTheme.space4))
        .listRowBackground(SbuTheme.surfaceRaised)
        .listRowSeparatorTint(SbuTheme.line)
        .accessibilityElement(children: .combine)
    }

    private func word(_ renewal: RenewalStatus) -> LocalizedStringKey {
        switch renewal {
        case .paused: "In pausa"
        case .cancelled: "Annullato"
        case .finished: "Concluso"
        case let .renews(days, _):
            switch days {
            case 0: "Rinnova oggi"
            case 1: "Rinnova domani"
            default: "Rinnova tra ^[\(days) giorno](inflect: true)"
            }
        case let .trialEnds(days, _):
            switch days {
            case 0: "La prova finisce oggi"
            case 1: "La prova finisce domani"
            default: "La prova finisce tra ^[\(days) giorno](inflect: true)"
            }
        }
    }
}

#Preview("Light") {
    List { SubscriptionRow(subscription: .preview, today: .now) }
        .modelContainer(.preview)
}

#Preview("Dark") {
    List { SubscriptionRow(subscription: .preview, today: .now) }
        .modelContainer(.preview)
        .preferredColorScheme(.dark)
}
