import SbuKit
import SwiftUI

/// The import's sheet: reading, "Chi sei?", or why the file didn't become a chat.
struct ImportSheetView: View {
    let library: ChatLibrary
    let sheet: ImportSheet

    var body: some View {
        NavigationStack {
            Group {
                switch sheet {
                case .reading:
                    ImportProgressView(progress: library.progress, cancel: library.cancelImport)
                case let .owner(request):
                    WhoAreYouView(request: request) { sender in
                        Task { await library.chooseOwner(sender, for: request) }
                    }
                case let .failure(failure):
                    ImportFailureView(failure: failure)
                }
            }
            .background(SbuTheme.surface)
        }
        .presentationDetents(sheet == .reading ? [.medium] : [.large])
        // Reading can only be stopped with Annulla, so the file is never left half-imported.
        .interactiveDismissDisabled(sheet == .reading)
        .tint(SbuTheme.accentChats)
    }
}
