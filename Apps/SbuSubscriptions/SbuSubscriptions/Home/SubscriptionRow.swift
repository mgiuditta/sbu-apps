import SbuKit
import SwiftUI

/// One subscription on the home: its sign, name and cycle, then the price and when it's due.
struct SubscriptionRow: View {
    let subscription: Subscription
    let today: Date

    var body: some View {
        SbuListRow(
            "\(subscription.name)",
            subtitle: subscription.cycle.label,
            systemImage: Monogram.systemImage(for: subscription.name),
            // Not the accent: on this screen it belongs to the figure's full stop.
            iconBackground: SbuTheme.surfaceSunken,
            iconForeground: SbuTheme.inkMuted,
            amount: subscription.price.formatted(.currency(code: subscription.currencyCode)),
            status: status
        )
    }

    private var status: LocalizedStringKey {
        switch subscription.status {
        case .paused: return "In pausa"
        case .cancelled: return "Annullato"
        case .active: break
        }
        if subscription.isInTrial(on: today), let end = subscription.trialEndDate {
            return "Prova fino al \(end.formatted(.dateTime.day().month()))"
        }
        guard let next = subscription.nextPayment(after: today) else { return "Concluso" }
        switch DueDay(next, from: today, in: .current) {
        case .today: return "Oggi"
        case .tomorrow: return "Domani"
        case let .inDays(days): return "Tra \(days) giorni"
        case let .on(date): return "\(date.formatted(.dateTime.day().month()))"
        }
    }
}

#Preview("Light") {
    List { SubscriptionRow(subscription: .preview, today: .now) }
}

#Preview("Dark") {
    List { SubscriptionRow(subscription: .preview, today: .now) }
        .preferredColorScheme(.dark)
}
