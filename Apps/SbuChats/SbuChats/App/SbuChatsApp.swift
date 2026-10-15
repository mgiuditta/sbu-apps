import SwiftUI

@main
struct SbuChatsApp: App {
    @State private var library: ChatLibrary = Self.makeLibrary()

    var body: some Scene {
        WindowGroup {
            RootView(library: library)
                // A chat shared from the messaging app ("Copy to Sbu Chats") or opened from Files.
                .onOpenURL { url in
                    library.importFile(at: url)
                }
                .task {
                    await Self.seedIfNeeded(library)
                    await library.reload()
                }
        }
    }

    // ponytail: no recovery screen; a store that can't open is a bug to fix, never a reason to start empty.
    private static func makeLibrary() -> ChatLibrary {
        do {
            if LaunchMode.isDemo {
                let defaults = UserDefaults(suiteName: "demo-\(UUID().uuidString)") ?? .standard
                return ChatLibrary(store: try ChatStore(url: nil), knownOwners: KnownOwners(defaults: defaults))
            }
            return ChatLibrary(store: try ChatStore(url: ChatStore.defaultURL))
        } catch {
            fatalError("Chat store failed to open: \(error)")
        }
    }

    /// Screenshots and flow tests start with the sample chat and you chosen.
    private static func seedIfNeeded(_ library: ChatLibrary) async {
        if let text = LaunchMode.demoImportText {
            let folder = URL.temporaryDirectory.appending(path: "demo-\(UUID().uuidString)")
            let url = folder.appending(path: "Lista.txt")
            try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
            try? Data(text.utf8).write(to: url)
            library.importFile(at: url)
        }
        guard LaunchMode.seedsSample else { return }
        let language = SampleChat.appLanguage
        let folder = URL.temporaryDirectory.appending(path: "seed-\(UUID().uuidString)")
        let url = folder.appending(path: SampleChat.fileName(language))
        try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        try? Data(SampleChat.text(language, endingBefore: .now).utf8).write(to: url)
        _ = try? await library.store.importChat(from: url, knownOwners: [SampleChat.owner(language)])
        try? FileManager.default.removeItem(at: folder)
    }
}
