import SwiftUI

/// A folder's name as the bar title, for the back button of what it opens. On screen the name is the
/// `SbuScreenTitle`, so the bar stays empty, as the shell keeps it at the top of the inventory.
struct FolderTitle: ViewModifier {
    let name: String?

    func body(content: Content) -> some View {
        if let name {
            content
                .navigationTitle(name)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Text(verbatim: "")
                            .accessibilityHidden(true)
                    }
                }
        } else {
            content
        }
    }
}
