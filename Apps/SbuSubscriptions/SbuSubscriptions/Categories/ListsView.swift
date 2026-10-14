import SwiftData
import SwiftUI

/// Settings → Liste: lists such as Famiglia or Lavoro, to add, rename or delete.
struct ListsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \SubscriptionList.order) private var lists: [SubscriptionList]
    @State private var newName = ""
    @State private var pendingDelete: SubscriptionList?

    var body: some View {
        List {
            Section {
                ForEach(lists) { list in
                    ListNameField(list: list)
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

    var body: some View {
        TextField("Nome", text: $list.name)
    }
}

#Preview("Light") {
    NavigationStack { ListsView() }
        .modelContainer(.preview)
}

#Preview("Dark") {
    NavigationStack { ListsView() }
        .modelContainer(.preview)
        .preferredColorScheme(.dark)
}
