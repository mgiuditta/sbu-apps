import SbuKit
import SwiftUI

extension View {
    /// Pins one action to the bottom of the screen, over the content, on paper.
    func bottomAction(@ViewBuilder _ action: () -> some View) -> some View {
        safeAreaInset(edge: .bottom, spacing: 0) {
            action()
                .padding(.horizontal, SbuTheme.space4)
                .padding(.vertical, SbuTheme.space3)
                .frame(maxWidth: .infinity)
                .background(SbuTheme.paper)
        }
    }
}
