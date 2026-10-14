import SbuKit
import SwiftData
import SwiftUI

/// Settings → Liste: lists such as Famiglia or Lavoro, to add, rename or delete.
struct ListsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(ListSharing.self) private var sharing
    @Query(sort: \SubscriptionList.order) private var lists: [SubscriptionList]
    @State private var newName = ""
    @State private var pendingDelete: SubscriptionList?

    var body: some View {
        List {
            Section {
                ForEach(lists) { list in
                    HStack {
                        ListNameField(list: list, participants: sharing.participants[list.uuid])
                        ShareListButton(list: list, sharing: sharing)
                    }
                }
                .onDelete { pendingDelete = $0.first.map { lists[$0] } }
            }
            Section {
                TextField("Nuova lista", text: $newName)
                    .onSubmit(add)
                    .submitLabel(.done)
                    .accessibilityIdentifier("newList")
            } footer: {
                Text("Per esempio Famiglia o Lavoro. Ogni abbonamento può stare in una lista.")
            }
            Section {
            } footer: {
                Text(sharing.isAvailable
                     ? "Condividi una lista con chi vuoi, tramite iCloud: la vede in sola lettura, con il totale. Note, siti, metodi di pagamento e promemoria restano qui."
                     : "Per condividere una lista accedi a iCloud nelle Impostazioni dell'iPhone.")
            }
        }
        .navigationTitle("Liste")
        .navigationBarTitleDisplayMode(.inline)
        .confirmationDialog("Eliminare la lista?", isPresented: isConfirmingDelete, titleVisibility: .visible, presenting: pendingDelete) { list in
            Button("Elimina \(list.name)", role: .destructive) { delete(list) }
        } message: { _ in
            Text("Gli abbonamenti restano, senza lista.")
        }
    }

    private var isConfirmingDelete: Binding<Bool> {
        Binding { pendingDelete != nil } set: { if !$0 { pendingDelete = nil } }
    }

    private func add() {
        let name = newName.trimmingCharacters(in: .whitespaces)
        guard !name.isEmpty else { return }
        modelContext.insert(SubscriptionList(name: name, order: (lists.last?.order ?? 0) + 1))
        try? modelContext.save()
        newName = ""
    }

    private func delete(_ list: SubscriptionList) {
        modelContext.delete(list)
        try? modelContext.save()
    }
}

/// A list's name, editable in place.
private struct ListNameField: View {
    @Bindable var list: SubscriptionList
    /// People it's shared with, `nil` when it isn't shared.
    let participants: Int?

    var body: some View {
        VStack(alignment: .leading) {
            TextField("Nome", text: $list.name)
            if let participants {
                Text("Condivisa con ^[\(participants) persona](inflect: true)")
                    .font(SbuTheme.footnote)
                    .foregroundStyle(SbuTheme.inkMuted)
            }
        }
    }
}

#Preview("Light") {
    NavigationStack { ListsView() }
        .modelContainer(.preview)
        .environment(ListSharing(outbox: nil))
}

#Preview("Dark") {
    NavigationStack { ListsView() }
        .modelContainer(.preview)
        .environment(ListSharing(outbox: nil))
        .preferredColorScheme(.dark)
}
