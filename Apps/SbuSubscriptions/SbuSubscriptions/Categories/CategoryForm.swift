import SwiftUI

/// The name and symbol of a category, for a new one or one you're editing.
struct CategoryForm: View {
    @Binding var name: String
    @Binding var symbol: String
    /// The built-in name, shown while you haven't typed your own.
    var placeholder: String = ""

    var body: some View {
        Section("Nome") {
            TextField(placeholder.isEmpty ? String(localized: "Nome") : placeholder, text: $name)
                .accessibilityIdentifier("categoryName")
        }
        Section("Simbolo") {
            SymbolPicker(symbol: $symbol)
        }
    }
}
