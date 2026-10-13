import SbuKit
import SwiftUI

/// A list of the ☰ menu, by name and symbol.
struct CategoryLabel: View {
    let category: PlayerCategory

    var body: some View {
        Label { Text(category.title) } icon: { Image(systemName: category.systemImage) }
    }
}

#Preview("Light") {
    CategoryLabel(category: .group(.rain))
}

#Preview("Dark") {
    CategoryLabel(category: .favorites)
        .preferredColorScheme(.dark)
}
