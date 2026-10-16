import SbuKit
import SwiftUI

/// One subscription on the home: its sign and name, when it renews in days and as a date, then the price and cycle.
struct SubscriptionRow: View {
    let subscription: Subscription
    let today: Date

    var body: some View {
        SbuListRow(
            "\(subscription.name)",
            subtitle: subtitle,
            systemImage: subscription.category?.symbol ?? Monogram.systemImage(for: subscription.name),
            // Not the accent: on this screen it belongs to the figure's full stop.
            iconBackground: SbuTheme.surfaceSunken,
            iconForeground: SbuTheme.inkMuted,
            amount: subscription.price.formatted(.currency(code: subscription.currencyCode)),
            status: subscription.cycle.label
        )
    }

    private var subtitle: LocalizedStringKey {
        let renewal = RenewalStatus(
            status: subscription.status,
            trialEnd: subscription.isInTrial(on: today) ? subscription.trialEndDate : nil,
            nextPayment: subscription.nextPayment(after: today),
            today: today,
            calendar: .current
        )
        switch renewal {
        case .paused: return "In pausa"
        case .cancelled: return "Annullato"
        case .finished: return "Concluso"
        case let .renews(days, date):
            let day = Self.shortDate(date)
            switch days {
            case 0: return "Rinnova oggi · \(day)"
            case 1: return "Rinnova domani · \(day)"
            default: return "Rinnova tra ^[\(days) giorno](inflect: true) · \(day)"
            }
        case let .trialEnds(days, date):
            let day = Self.shortDate(date)
            switch days {
            case 0: return "La prova finisce oggi · \(day)"
            case 1: return "La prova finisce domani · \(day)"
            default: return "La prova finisce tra ^[\(days) giorno](inflect: true) · \(day)"
            }
        }
    }

    /// "19 ott", kept on one line: the row may wrap before the date, never inside it.
    private static func shortDate(_ date: Date) -> String {
        date.formatted(.dateTime.day().month(.abbreviated)).replacing(" ", with: "\u{00A0}")
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
