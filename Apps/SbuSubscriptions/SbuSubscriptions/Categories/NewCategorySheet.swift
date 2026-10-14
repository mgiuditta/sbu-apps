import SwiftData
import SwiftUI

/// A sheet to make a category of your own.
struct NewCategorySheet: View {
    let order: Int

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var symbol = BuiltInCategory.other.symbol

    var body: some View {
        NavigationStack {
            Form {
                CategoryForm(name: $name, symbol: $symbol)
            }
            .navigationTitle("Nuova categoria")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annulla") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Aggiungi", action: add)
                        .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }

    private func add() {
        modelContext.insert(SubscriptionCategory(customName: name.trimmingCharacters(in: .whitespaces), symbol: symbol, order: order))
        try? modelContext.save()
        dismiss()
    }
}
