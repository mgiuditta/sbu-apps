import SwiftUI

/// Settings → the categories and lists you file subscriptions under.
struct OrganizeSection: View {
    var body: some View {
        Section("Organizza") {
            NavigationLink("Categorie") { CategoriesView() }
            NavigationLink("Liste") { ListsView() }
        }
    }
}
