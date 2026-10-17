import SbuKit
import SwiftUI

/// The final review: everything marked waits here. Tap an item to take it out; delete the rest
/// with one confirmed action, then the system asks once more. A deletion closes with
/// "Liberato", then the result opens.
struct BinScreen: View {
    let model: CleanModel

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var result: DeletionResult?
    /// The deletion just done, waiting for the Closure to end before its sheet opens.
    @State private var freed: DeletionResult?
    @State private var isClosing = false
    @State private var isDeleting = false
    @State private var failed = false

    private let columns = [GridItem(.adaptive(minimum: 100), spacing: SbuTheme.space1)]

    var body: some View {
        let ids = model.state.trash.filter { model.itemsByID[$0] != nil }
        ScrollView {
            VStack(alignment: .leading, spacing: SbuTheme.space4) {
                Group {
                    if ids.isEmpty {
                        SbuEmpty(sentence: "Il cestino è vuoto. Quello che metti nel cestino scorrendo o dai duplicati arriva qui.")
                    } else {
                        SpaceStat(label: "Nel cestino", bytes: model.trashBytes, context: "\(ids.count) elementi")
                    }
                }
                // Once per deletion: the figure gives way to the word, then the result opens.
                .sbuClosure($isClosing, word: "Liberato")

                if !ids.isEmpty {
                    Text("Tocca un elemento per toglierlo dal cestino.")
                        .font(SbuTheme.footnote)
                        .foregroundStyle(SbuTheme.inkMuted)

                    LazyVGrid(columns: columns, spacing: SbuTheme.space1) {
                        ForEach(ids, id: \.self) { id in
                            if let item = model.itemsByID[id] {
                                BinTile(item: item) {
                                    restore(id)
                                }
                            }
                        }
                    }
                }

                RecentlyDeletedNote()
            }
            .padding(SbuTheme.space4)
            // The empty bin is a paper area; the photos never sit on the grid.
            .sbuPaper(grid: ids.isEmpty)
        }
        .background(SbuTheme.paper)
        .navigationTitle("Cestino")
        .navigationBarTitleDisplayMode(.inline)
        .bottomAction {
            if !ids.isEmpty {
                SbuButton(
                    "Elimina \(ids.count) elementi",
                    kind: .destructive,
                    confirmationTitle: "Eliminare \(ids.count) elementi dalla libreria Foto?",
                    action: delete
                )
                .disabled(isDeleting)
                .accessibilityIdentifier("bottomAction")
            }
        }
        .sheet(item: $result) { result in
            DeletionResultSheet(result: result)
        }
        .alert("Non è stato possibile eliminare", isPresented: $failed) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Non è stato eliminato niente. Riprova tra poco.")
        }
        .onChange(of: isClosing) { _, isClosing in
            guard !isClosing, let freed else { return }
            self.freed = nil
            result = freed
        }
        .onDisappear {
            // Left during the Closure: the space is freed and counted, the sheet has nowhere to open.
            freed = nil
            isClosing = false
        }
    }

    private func restore(_ id: String) {
        withAnimation(SbuMotion.animation(SbuMotion.short, reduceMotion: reduceMotion)) {
            model.restore(id)
        }
    }

    private func delete() {
        isDeleting = true
        Task {
            defer { isDeleting = false }
            do {
                freed = try await model.deleteTrash()
                isClosing = true
            } catch LibraryError.cancelled {
                // The user said no in the system dialog: the bin stays, nothing to say.
            } catch {
                failed = true
            }
        }
    }
}

#Preview("Light") {
    BinPreview()
}

#Preview("Dark") {
    BinPreview()
        .preferredColorScheme(.dark)
}

private struct BinPreview: View {
    @State private var model = CleanModel.preview

    var body: some View {
        NavigationStack {
            BinScreen(model: model)
        }
        .environment(\.sbuAccent, .clean)
        .task {
            await model.reload()
            model.moveToTrash(model.items.prefix(7).map(\.id))
        }
    }
}
