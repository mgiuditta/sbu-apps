import SbuKit
import SwiftUI

/// The buttons under the card, the same as the swipe: Elimina on the left, Tieni on the right,
/// and in between Dopo and Tieni sempre.
struct SwipeControls: View {
    let decide: (SwipeDecision) -> Void

    var body: some View {
        HStack(alignment: .top, spacing: SbuTheme.space2) {
            SwipeControlButton(title: "Elimina", systemImage: "trash", role: .trash) { decide(.trash) }
            SwipeControlButton(title: "Dopo", systemImage: "bookmark", role: .secondary) { decide(.later) }
            SwipeControlButton(title: "Tieni sempre", systemImage: "lock", role: .secondary) { decide(.keepForever) }
            SwipeControlButton(title: "Tieni", systemImage: "checkmark", role: .keep) { decide(.keep) }
        }
        // The card needs the room: past this size the words show in the large content viewer.
        .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
    }
}

#Preview("Light") {
    SwipeControls { _ in }
        .padding()
        .environment(\.sbuAccent, .clean)
}

#Preview("Dark") {
    SwipeControls { _ in }
        .padding()
        .environment(\.sbuAccent, .clean)
        .preferredColorScheme(.dark)
}
