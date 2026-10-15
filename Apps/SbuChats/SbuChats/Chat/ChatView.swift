import SbuKit
import SwiftUI

/// The tool screen: how many messages, then each person's numbers, over the chosen period.
struct ChatView: View {
    let library: ChatLibrary
    let chatID: Int64

    @Environment(\.dismiss) private var dismiss
    @State private var period: ChatPeriod
    @State private var statistics: ChatStatistics?
    @State private var addedByMerge: Int?
    @State private var isRenaming = false
    @State private var newTitle = ""
    @State private var isConfirmingDelete = false

    private var chat: ChatSummary? { library.chat(id: chatID) }

    /// What the numbers depend on: the chat (renamed, re-imported, you chosen) and the period.
    private struct LoadKey: Hashable {
        let chat: ChatSummary?
        let period: ChatPeriod
    }

    init(library: ChatLibrary, chatID: Int64) {
        self.library = library
        self.chatID = chatID
        _period = State(initialValue: ChatPeriod(chat: library.chat(id: chatID)))
    }

    var body: some View {
        List {
            if let chat {
                ChatTotalSection(total: statistics?.totalMessages, statistics: statistics)
                if let addedByMerge {
                    MergeNoticeSection(added: addedByMerge)
                }
                if !chat.ownerChosen {
                    OwnerPromptSection { Task { await library.askOwner(for: chat) } }
                }
                ChatPeriodSection(period: $period, chat: chat)
                if let statistics {
                    ChatStatisticsSections(
                        statistics: statistics,
                        store: library.store,
                        chat: chat,
                        bounds: period.bounds(for: chat)
                    )
                }
                ExportLimitSection(chat: chat)
            }
        }
        .listStyle(.insetGrouped)
        .listSectionSpacing(SbuTheme.space6)
        .scrollContentBackground(.hidden)
        .background(SbuTheme.surface)
        .navigationTitle(Text(verbatim: chat?.title ?? ""))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if let chat {
                ToolbarItem(placement: .topBarTrailing) {
                    ChatMenu(
                        chooseOwner: { Task { await library.askOwner(for: chat) } },
                        rename: { startRenaming(chat) },
                        delete: { isConfirmingDelete = true }
                    )
                }
            }
        }
        .task(id: LoadKey(chat: chat, period: period)) {
            await load()
        }
        .onAppear {
            if addedByMerge == nil { addedByMerge = library.takeAddedByMerge(chatID: chatID) }
        }
        .onChange(of: chat == nil) { _, isGone in
            if isGone { dismiss() }
        }
        .alert(Text("Rinomina la chat"), isPresented: $isRenaming) {
            TextField(text: $newTitle) { Text("Nome") }
            Button("Annulla", role: .cancel) {}
            Button("Rinomina", action: rename)
        }
        .confirmationDialog(Text("Eliminare “\(chat?.title ?? "")”?"), isPresented: $isConfirmingDelete, titleVisibility: .visible) {
            Button("Elimina", role: .destructive, action: delete)
        } message: {
            Text("I messaggi e i numeri di questa chat spariscono da Sbu Chats. La chat nell'app di messaggi resta com'è.")
        }
    }

    private func load() async {
        guard let chat else { return }
        let bounds = period.bounds(for: chat)
        let result = try? await library.store.statistics(chatID: chat.id, from: bounds.start, to: bounds.end, owner: chat.owner)
        guard !Task.isCancelled else { return }
        statistics = result ?? .empty
    }

    private func startRenaming(_ chat: ChatSummary) {
        newTitle = chat.title
        isRenaming = true
    }

    private func rename() {
        guard let chat else { return }
        Task { await library.rename(chat, to: newTitle) }
    }

    private func delete() {
        guard let chat else { return }
        Task { await library.delete(chat) }
    }
}

#Preview("Light") {
    ChatViewPreview()
}

#Preview("Dark") {
    ChatViewPreview()
        .preferredColorScheme(.dark)
}

private struct ChatViewPreview: View {
    @State private var library = ChatLibrary.preview

    var body: some View {
        NavigationStack {
            ChatView(library: library, chatID: 1)
        }
        .tint(SbuTheme.accentChats)
        .task {
            library.importSample()
        }
    }
}
