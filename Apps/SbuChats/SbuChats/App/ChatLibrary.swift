import Foundation
import Observation

/// The app's state: the chats, the import in progress, and which chat is open.
@Observable
final class ChatLibrary {
    let store: ChatStore
    private(set) var chats: [ChatSummary] = []
    /// The import sheet, if one is up.
    var sheet: ImportSheet?
    /// How much of the file the import has read, from 0 to 1.
    private(set) var progress = 0.0
    /// The chat to show, set after an import.
    var openedChatID: Int64?
    /// Messages a re-import added, by chat, until the chat screen has said so once.
    private(set) var addedByMerge: [Int64: Int] = [:]

    @ObservationIgnored let knownOwners: KnownOwners
    @ObservationIgnored private var importTask: Task<Void, Never>?

    init(store: ChatStore, knownOwners: KnownOwners = KnownOwners(defaults: .standard)) {
        self.store = store
        self.knownOwners = knownOwners
    }

    func chat(id: Int64) -> ChatSummary? {
        chats.first { $0.id == id }
    }

    /// Reads the chats from the store.
    func reload() async {
        chats = (try? await store.chats()) ?? []
    }

    // MARK: - Import

    /// Imports a `.zip` or `.txt` shared to the app or picked in Files.
    func importFile(at url: URL) {
        guard importTask == nil else { return }
        progress = 0
        sheet = .reading
        importTask = Task {
            await runImport(url)
            importTask = nil
        }
    }

    /// "Prova con una chat di esempio": the same path as a real file.
    func importSample() {
        let language = SampleChat.appLanguage
        let folder = URL.temporaryDirectory.appending(path: "sample-\(UUID().uuidString)")
        let url = folder.appending(path: SampleChat.fileName(language))
        do {
            try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
            try Data(SampleChat.text(language, endingBefore: .now).utf8).write(to: url)
            importFile(at: url)
        } catch {
            sheet = .failure(.unreadableFile)
        }
    }

    func cancelImport() {
        importTask?.cancel()
    }

    private func runImport(_ url: URL) async {
        let isScoped = url.startAccessingSecurityScopedResource()
        defer {
            if isScoped { url.stopAccessingSecurityScopedResource() }
            removeIfCopiedForUs(url)
        }
        do {
            let outcome = try await store.importChat(from: url, knownOwners: Set(knownOwners.names)) { fraction in
                Task { @MainActor in self.progress = fraction }
            }
            await reload()
            if outcome.merged { addedByMerge[outcome.chatID] = outcome.addedMessages }
            if outcome.needsOwner {
                sheet = .owner(OwnerRequest(chatID: outcome.chatID, senders: outcome.senders))
            } else {
                sheet = nil
                openedChatID = outcome.chatID
            }
        } catch let failure as ImportFailure {
            sheet = .failure(failure)
        } catch is CancellationError {
            sheet = nil
        } catch {
            sheet = .failure(.unreadableFile)
        }
    }

    /// iOS copies shared files into `Documents/Inbox` and our sample lives in the temporary folder:
    /// both are the app's own copies, removed once read. A file picked in Files is never touched.
    private func removeIfCopiedForUs(_ url: URL) {
        let path = url.standardizedFileURL.path(percentEncoded: false)
        let inbox = URL.documentsDirectory.appending(path: "Inbox").standardizedFileURL.path(percentEncoded: false)
        let temporary = URL.temporaryDirectory.standardizedFileURL.path(percentEncoded: false)
        if path.hasPrefix(inbox) || path.hasPrefix(temporary) {
            try? FileManager.default.removeItem(at: url)
        }
    }

    // MARK: - Who you are

    /// Opens "Chi sei?" for a chat already imported.
    func askOwner(for chat: ChatSummary) async {
        let senders = (try? await store.senders(chatID: chat.id)) ?? []
        sheet = .owner(OwnerRequest(chatID: chat.id, senders: senders, current: chat.owner, opensChat: false))
    }

    /// Saves your answer; `nil` means none of the senders is you.
    func chooseOwner(_ sender: String?, for request: OwnerRequest) async {
        try? await store.setOwner(chatID: request.chatID, sender: sender)
        if let sender { knownOwners.remember(sender) }
        await reload()
        closeOwnerSheet(request)
    }

    /// Closes "Chi sei?", with or without an answer: it can be given later from the chat.
    func closeOwnerSheet(_ request: OwnerRequest) {
        sheet = nil
        if request.opensChat, openedChatID != request.chatID { openedChatID = request.chatID }
    }

    // MARK: - Chats

    func rename(_ chat: ChatSummary, to title: String) async {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        try? await store.rename(chatID: chat.id, title: trimmed)
        await reload()
    }

    func delete(_ chat: ChatSummary) async {
        try? await store.delete(chatID: chat.id)
        if openedChatID == chat.id { openedChatID = nil }
        addedByMerge[chat.id] = nil
        await reload()
    }

    /// The messages the last re-import added to `chatID`, said once.
    func takeAddedByMerge(chatID: Int64) -> Int? {
        defer { addedByMerge[chatID] = nil }
        return addedByMerge[chatID]
    }
}
