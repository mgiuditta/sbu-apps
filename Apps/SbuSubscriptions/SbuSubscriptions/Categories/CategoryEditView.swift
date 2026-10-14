import SwiftUI

/// Rename a category or change its symbol; a built-in one keeps its name in your language until you type another.
struct CategoryEditView: View {
    @Bindable var category: SubscriptionCategory

    var body: some View {
        Form {
            CategoryForm(name: $category.customName, symbol: $category.symbol, placeholder: builtInName)
        }
        .navigationTitle(category.name)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var builtInName: String {
        category.key.flatMap(BuiltInCategory.init(rawValue:))?.name ?? ""
    }
}
