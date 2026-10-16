import SbuKit
import SwiftUI

/// A subscription's row that opens its detail sheet, with the chevron of a row that leads somewhere.
struct SubscriptionButton: View {
    let subscription: Subscription
    let today: Date
    let open: (Subscription) -> Void

    var body: some View {
        Button(action: openSubscription) {
            HStack(spacing: SbuTheme.space2) {
                SubscriptionRow(subscription: subscription, today: today)
                Image(systemName: "chevron.right")
                    .font(SbuTheme.footnote)
                    .fontWeight(.medium)
                    .imageScale(.medium)
                    .foregroundStyle(SbuTheme.inkMuted)
                    .accessibilityHidden(true)
            }
        }
    }

    private func openSubscription() {
        open(subscription)
    }
}

#Preview("Light") {
    List { SubscriptionButton(subscription: .preview, today: .now) { _ in } }
        .modelContainer(.preview)
}

#Preview("Dark") {
    List { SubscriptionButton(subscription: .preview, today: .now) { _ in } }
        .modelContainer(.preview)
        .preferredColorScheme(.dark)
}
