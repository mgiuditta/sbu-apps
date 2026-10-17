import SbuKit
import SwiftUI

/// The most used words and emoji, for everyone or one person, over the chat screen's period.
struct WordsView: View {
    let store: ChatStore
    let chatID: Int64
    let bounds: (start: Date?, end: Date?)
    let senders: [String]
    let owner: String?

    @State private var kind: TermKind = .words
    /// One person's ranking, or everyone's when `nil`.
    @State private var sender: String?
    @State private var terms: TermStatistics?

    var body: some View {
        List {
            Section {
                Picker("Mostra", selection: $kind) {
                    ForEach(TermKind.allCases) { kind in
                        Text(kind.title).tag(kind)
                    }
                }
                .pickerStyle(.segmented)
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets())
            }

            if senders.count > 1 {
                Section {
                    Picker(selection: $sender) {
                        Text("Tutti").tag(String?.none)
                        ForEach(senders, id: \.self) { name in
                            senderLabel(name).tag(Optional(name))
                        }
                    } label: {
                        Text("Di chi").foregroundStyle(SbuTheme.ink)
                    }
                    // In ink, as on the chat screen: the same control looks the same everywhere.
                    .tint(SbuTheme.ink)
                }
                .listRowBackground(SbuTheme.surfaceRaised)
            }

            Section {
                if let terms {
                    let ranked = ranking(terms)
                    if ranked.isEmpty {
                        Text(kind == .words ? "Nessuna parola in questo periodo" : "Nessuna emoji in questo periodo")
                            .font(SbuTheme.body)
                            .foregroundStyle(SbuTheme.inkMuted)
                    } else {
                        ForEach(Array(ranked.enumerated()), id: \.element.term) { index, term in
                            RankedTermRow(rank: index + 1, term: term)
                        }
                    }
                } else {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                }
            } footer: {
                if kind == .words {
                    Text("Senza le parole più comuni della lingua della chat (articoli, preposizioni, pronomi), senza link e numeri.")
                }
            }
            .listRowBackground(SbuTheme.surfaceRaised)
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(SbuTheme.paper)
        .navigationTitle(Text("Parole ed emoji"))
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await load()
        }
    }

    private func senderLabel(_ name: String) -> Text {
        name == owner ? Text("Tu · \(name)") : Text(verbatim: name)
    }

    private func ranking(_ terms: TermStatistics) -> [RankedTerm] {
        switch (kind, sender) {
        case (.words, nil): terms.words
        case (.emoji, nil): terms.emoji
        case let (.words, name?): terms.wordsBySender[name] ?? []
        case let (.emoji, name?): terms.emojiBySender[name] ?? []
        }
    }

    private func load() async {
        let result = try? await store.terms(chatID: chatID, from: bounds.start, to: bounds.end)
        terms = result ?? .empty
    }
}

#Preview("Light") {
    NavigationStack {
        WordsView(store: ChatLibrary.preview.store, chatID: 1, bounds: (nil, nil), senders: ["Giulia", "Marco"], owner: "Giulia")
    }
}

#Preview("Dark") {
    NavigationStack {
        WordsView(store: ChatLibrary.preview.store, chatID: 1, bounds: (nil, nil), senders: ["Giulia", "Marco"], owner: "Giulia")
    }
    .preferredColorScheme(.dark)
}
