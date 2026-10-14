import SbuKit
import SwiftData
import SwiftUI

/// Settings → Categorie: every category with its symbol, to rename, add or delete.
struct CategoriesView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \SubscriptionCategory.order) private var categories: [SubscriptionCategory]
    @State private var isAdding = false
    @State private var pendingDelete: SubscriptionCategory?

    var body: some View {
        List {
            ForEach(categories) { category in
                NavigationLink {
                    CategoryEditView(category: category)
                } label: {
                    Label(category.name, systemImage: category.symbol)
                }
            }
            .onDelete { pendingDelete = $0.first.map { categories[$0] } }
        }
        .navigationTitle("Categorie")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            Button("Aggiungi categoria", systemImage: "plus") { isAdding = true }
        }
        .sheet(isPresented: $isAdding) {
            NewCategorySheet(order: (categories.last?.order ?? 0) + 1)
        }
        .confirmationDialog("Eliminare la categoria?", isPresented: isConfirmingDelete, titleVisibility: .visible, presenting: pendingDelete) { category in
            Button("Elimina \(category.name)", role: .destructive) { delete(category) }
        } message: { _ in
            Text("Gli abbonamenti restano, senza categoria.")
        }
    }

    private var isConfirmingDelete: Binding<Bool> {
        Binding { pendingDelete != nil } set: { if !$0 { pendingDelete = nil } }
    }

    private func delete(_ category: SubscriptionCategory) {
        modelContext.delete(category)
        try? modelContext.save()
    }
}

#Preview("Light") {
    NavigationStack { CategoriesView() }
        .modelContainer(.preview)
}

#Preview("Dark") {
    NavigationStack { CategoriesView() }
        .modelContainer(.preview)
        .preferredColorScheme(.dark)
}
