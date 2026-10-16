import SwiftUI

/// A section closed by default at the bottom of the home, for subscriptions you no longer pay.
struct CollapsedSection: View {
    let title: LocalizedStringKey
    let subscriptions: [Subscription]
    let today: Date
    let open: (Subscription) -> Void

    @State private var isExpanded = false

    var body: some View {
        if !subscriptions.isEmpty {
            Section {
                DisclosureGroup(isExpanded: $isExpanded) {
                    ForEach(subscriptions) { subscription in
                        SubscriptionButton(subscription: subscription, today: today, open: open)
                    }
                } label: {
                    LabeledContent(title) {
                        Text(subscriptions.count, format: .number)
                    }
                }
            }
        }
    }
}
