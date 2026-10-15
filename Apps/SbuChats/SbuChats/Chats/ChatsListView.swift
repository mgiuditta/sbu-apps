import SbuKit
import SwiftUI
import UniformTypeIdentifiers

/// The first screen: the imported chats, or how to bring in the first one.
struct ChatsListView: View {
    @Bindable var library: ChatLibrary
    @State private var isPickingFile = false
    @State private var chatToDelete: ChatSummary?
    @State private var isConfirmingDelete = false

    var body: some View {
        List {
            if library.chats.isEmpty {
                Section {
                    EmptyChatsView(pickFile: pickFile, trySample: library.importSample)
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                }
            } else {
                Section {
                    ForEach(library.chats) { chat in
                        NavigationLink(value: chat.id) {
                            ChatRow(chat: chat)
                        }
                        .swipeActions {
                            Button("Elimina", systemImage: "trash", role: .destructive) {
                                confirmDelete(chat)
                            }
                        }
                    }
                } footer: {
                    Text("Per aggiornare una chat, esportala di nuovo: Sbu Chats aggiunge solo i messaggi nuovi.")
                        .font(SbuTheme.footnote)
                        .foregroundStyle(SbuTheme.inkMuted)
                }
                .listRowBackground(SbuTheme.surfaceRaised)
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                // In ink, like the gear: the accent belongs to the chat's full stop.
                Button("Importa una chat", systemImage: "square.and.arrow.down", action: pickFile)
                    .tint(SbuTheme.ink)
            }
        }
        .fileImporter(isPresented: $isPickingFile, allowedContentTypes: [.zip, .plainText, .text], onCompletion: picked)
        .navigationDestination(for: Int64.self) { id in
            ChatView(library: library, chatID: id)
        }
        .navigationDestination(item: $library.openedChatID) { id in
            ChatView(library: library, chatID: id)
        }
        .sheet(item: $library.sheet) { sheet in
            ImportSheetView(library: library, sheet: sheet)
        }
        .onChange(of: library.sheet) { old, new in
            // "Chi sei?" swiped away: the chat still opens, the question waits in the chat.
            if case let .owner(request) = old, new == nil {
                library.closeOwnerSheet(request)
            }
        }
        .confirmationDialog(deleteTitle, isPresented: $isConfirmingDelete, titleVisibility: .visible, presenting: chatToDelete) { chat in
            Button("Elimina", role: .destructive) {
                Task { await library.delete(chat) }
            }
        } message: { _ in
            Text("I messaggi e i numeri di questa chat spariscono da Sbu Chats. La chat nell'app di messaggi resta com'è.")
        }
    }

    private var deleteTitle: Text {
        Text("Eliminare “\(chatToDelete?.title ?? "")”?")
    }

    private func confirmDelete(_ chat: ChatSummary) {
        chatToDelete = chat
        isConfirmingDelete = true
    }

    private func pickFile() {
        isPickingFile = true
    }

    private func picked(_ result: Result<URL, any Error>) {
        if case let .success(url) = result {
            library.importFile(at: url)
        }
    }
}

#Preview("Light") {
    NavigationStack { ChatsListView(library: .preview) }
}

#Preview("Dark") {
    NavigationStack { ChatsListView(library: .preview) }
        .preferredColorScheme(.dark)
}
