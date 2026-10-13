import SbuKit
import SwiftUI

/// The final review: everything marked waits here. Tap an item to take it out; delete the rest
/// with one confirmed action, then the system asks once more.
struct BinScreen: View {
    let model: CleanModel

    @State private var result: DeletionResult?
    @State private var isDeleting = false
    @State private var failed = false

    private let columns = [GridItem(.adaptive(minimum: 100), spacing: SbuTheme.space1)]

    var body: some View {
        let ids = model.state.trash.filter { model.itemsByID[$0] != nil }
        ScrollView {
            VStack(alignment: .leading, spacing: SbuTheme.space4) {
                SpaceStat(label: "Nel cestino", bytes: model.trashBytes, context: "\(ids.count) elementi")

                if ids.isEmpty {
                    Text("Il cestino è vuoto. Quello che metti nel cestino scorrendo o dai duplicati arriva qui.")
                        .font(SbuTheme.body)
                        .foregroundStyle(SbuTheme.inkMuted)
                } else {
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
        }
        .background(SbuTheme.surface)
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
        .sensoryFeedback(.success, trigger: result)
    }

    private func restore(_ id: String) {
        withAnimation {
            model.restore(id)
        }
    }

    private func delete() {
        isDeleting = true
        Task {
            defer { isDeleting = false }
            do {
                result = try await model.deleteTrash()
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
        .tint(SbuTheme.accentClean)
        .task {
            await model.reload()
            model.moveToTrash(model.items.prefix(7).map(\.id))
        }
    }
}
