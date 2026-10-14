import SwiftUI

/// A section closed by default at the bottom of the home, for subscriptions you no longer pay.
struct CollapsedSection: View {
    let title: LocalizedStringKey
    let subscriptions: [Subscription]
    let today: Date

    @State private var isExpanded = false

    var body: some View {
        if !subscriptions.isEmpty {
            Section {
                DisclosureGroup(isExpanded: $isExpanded) {
                    ForEach(subscriptions) { SubscriptionRow(subscription: $0, today: today) }
                } label: {
                    LabeledContent(title) {
                        Text(subscriptions.count, format: .number)
                    }
                }
            }
        }
    }
}
