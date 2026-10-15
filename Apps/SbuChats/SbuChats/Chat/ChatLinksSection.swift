import SbuKit
import SwiftUI

/// The way to the charts, the words and emoji, and the search.
struct ChatLinksSection: View {
    let statistics: ChatStatistics
    let store: ChatStore
    let chat: ChatSummary
    let bounds: (start: Date?, end: Date?)

    var body: some View {
        Section {
            NavigationLink {
                ActivityView(statistics: statistics, owner: chat.owner, otherName: otherName)
            } label: {
                LinkLabel(title: "Attività", systemImage: "chart.bar")
            }
            .accessibilityIdentifier("activity")
            NavigationLink {
                WordsView(store: store, chatID: chat.id, bounds: bounds, senders: statistics.senders.map(\.name), owner: chat.owner)
            } label: {
                LinkLabel(title: "Parole ed emoji", systemImage: "textformat")
            }
            .accessibilityIdentifier("words")
            NavigationLink {
                SearchView(store: store, chatID: chat.id, senders: statistics.senders.map(\.name), owner: chat.owner)
            } label: {
                LinkLabel(title: "Cerca nei messaggi", systemImage: "magnifyingglass")
            }
            .accessibilityIdentifier("search")
        }
        .listRowBackground(SbuTheme.surfaceRaised)
    }

    /// In a two-person chat the other person's name; otherwise the charts say "Gli altri".
    private var otherName: String? {
        let others = statistics.senders.filter { !$0.isOwner }
        return others.count == 1 ? others[0].name : nil
    }
}
