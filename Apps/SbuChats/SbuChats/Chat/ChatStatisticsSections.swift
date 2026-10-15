import SbuKit
import SwiftUI

/// Everyone's numbers, the chat's facts, and the way to charts, words and search.
///
/// Up to four people, a section each; a group lists its people, each one a tap away.
struct ChatStatisticsSections: View {
    static let inlineSenderLimit = 4

    let statistics: ChatStatistics
    let store: ChatStore
    let chat: ChatSummary
    let bounds: (start: Date?, end: Date?)

    var body: some View {
        if statistics.senders.count <= Self.inlineSenderLimit {
            ForEach(statistics.senders) { sender in
                SenderSection(sender: sender)
            }
        } else {
            Section("Persone") {
                ForEach(statistics.senders) { sender in
                    NavigationLink {
                        SenderDetailView(sender: sender)
                    } label: {
                        SenderRow(sender: sender)
                    }
                }
            }
            .listRowBackground(SbuTheme.surfaceRaised)
        }
        ChatFactsSection(statistics: statistics)
        ChatLinksSection(statistics: statistics, store: store, chat: chat, bounds: bounds)
    }
}
