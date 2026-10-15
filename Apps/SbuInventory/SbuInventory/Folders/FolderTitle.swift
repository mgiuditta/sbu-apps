import SwiftUI

/// A folder's name as the inline title; the top of the inventory keeps the app's name from the shell.
struct FolderTitle: ViewModifier {
    let name: String?

    func body(content: Content) -> some View {
        if let name {
            content
                .navigationTitle(name)
                .navigationBarTitleDisplayMode(.inline)
        } else {
            content
        }
    }
}
