import SwiftUI

/// A search field that is there only while `isPresented`: a button shows it, already active,
/// and its Annulla hides it again.
struct RevealedSearch: ViewModifier {
    @Binding var isPresented: Bool
    @Binding var text: String
    let prompt: Text

    func body(content: Content) -> some View {
        if isPresented {
            content
                .searchable(text: $text, isPresented: $isPresented, placement: .navigationBarDrawer(displayMode: .always), prompt: prompt)
        } else {
            content
        }
    }
}
