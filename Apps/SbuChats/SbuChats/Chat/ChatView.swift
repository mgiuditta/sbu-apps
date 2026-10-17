import SbuKit
import SwiftUI

/// The chat's screen: how many messages, then each person's numbers, over the chosen period.
/// After an import the figure closes with "Importata", once.
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
    @State private var isClosing = false
    /// An import saved this chat: the Closure plays once the screen is still.
    @State private var isClosePending = false

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
        .background(SbuTheme.paper)
        // The figure stays above the rows, on its paper: in a List row its grid snap and
        // ViewThatFits kept the row resizing.
        .safeAreaInset(edge: .top, spacing: 0) {
            if chat != nil {
                ChatFigure(total: statistics?.totalMessages, statistics: statistics)
                    .sbuClosure($isClosing, word: "Importata")
                    .padding(SbuTheme.space4)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .sbuPaper(grid: true)
            }
        }
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
            closeIfImported()
        }
        // A re-import of the chat on screen, or "Chi sei?" answered over it.
        .onChange(of: library.importedChatID) { closeIfImported() }
        .onChange(of: library.sheet) { closeIfImported() }
        .task(id: isClosePending) {
            await closeAfterSettling()
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

    /// The Closure, once per import, when no sheet covers the figure.
    private func closeIfImported() {
        guard library.sheet == nil, library.takeImported(chatID: chatID) else { return }
        isClosePending = true
    }

    /// Lets the push or the sheet settle first, so the Closure plays whole on a still screen.
    private func closeAfterSettling() async {
        guard isClosePending else { return }
        try? await Task.sleep(for: .seconds(SbuTheme.motionBase))
        guard !Task.isCancelled else { return }
        isClosePending = false
        isClosing = true
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
        .environment(\.sbuAccent, .chats)
        .task {
            library.importSample()
        }
    }
}
