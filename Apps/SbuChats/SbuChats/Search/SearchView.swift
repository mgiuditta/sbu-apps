import SbuKit
import SwiftUI

/// Every message of the chat that contains the words you type, newest first.
struct SearchView: View {
    let store: ChatStore
    let chatID: Int64
    let senders: [String]
    let owner: String?

    @State private var query = ""
    /// One person's messages, or everyone's when `nil`.
    @State private var sender: String?
    @State private var hits: [SearchHit] = []
    @State private var total = 0
    @State private var hasSearched = false

    static let resultLimit = 200

    private struct SearchKey: Hashable {
        let query: String
        let sender: String?
    }

    var body: some View {
        List {
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

            if SearchQuery.match(for: query) == nil {
                Section {
                } footer: {
                    Text("Scrivi una o più parole: trovi i messaggi che le contengono tutte. Metti una frase tra virgolette per cercarla esatta, scrivi OR tra due parole per trovare l'una o l'altra.")
                }
            } else if hasSearched {
                Section {
                    ForEach(hits) { hit in
                        SearchHitRow(hit: hit, owner: owner)
                    }
                } header: {
                    if total > 0 { Text(countText) }
                }
                .listRowBackground(SbuTheme.surfaceRaised)
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(SbuTheme.surface)
        .overlay {
            if hasSearched, total == 0, SearchQuery.match(for: query) != nil {
                ContentUnavailableView.search(text: query)
            }
        }
        .searchable(text: $query, placement: .navigationBarDrawer(displayMode: .always), prompt: Text("Parole da cercare"))
        .autocorrectionDisabled()
        .navigationTitle(Text("Cerca nei messaggi"))
        .navigationBarTitleDisplayMode(.inline)
        .task(id: SearchKey(query: query, sender: sender)) {
            await search()
        }
    }

    private var countText: String {
        total > Self.resultLimit
            ? String(localized: "\(total) messaggi, qui i \(Self.resultLimit) più recenti")
            : String(localized: "\(total) messaggi")
    }

    private func senderLabel(_ name: String) -> Text {
        name == owner ? Text("Tu · \(name)") : Text(verbatim: name)
    }

    private func search() async {
        // Wait for a pause in typing before asking the store.
        try? await Task.sleep(for: .milliseconds(250))
        guard !Task.isCancelled else { return }
        let result = (try? await store.search(chatID: chatID, for: query, sender: sender, limit: Self.resultLimit)) ?? (hits: [], total: 0)
        guard !Task.isCancelled else { return }
        hits = result.hits
        total = result.total
        hasSearched = true
    }
}

#Preview("Light") {
    NavigationStack {
        SearchView(store: ChatLibrary.preview.store, chatID: 1, senders: ["Giulia", "Marco"], owner: "Giulia")
    }
}

#Preview("Dark") {
    NavigationStack {
        SearchView(store: ChatLibrary.preview.store, chatID: 1, senders: ["Giulia", "Marco"], owner: "Giulia")
    }
    .preferredColorScheme(.dark)
}
