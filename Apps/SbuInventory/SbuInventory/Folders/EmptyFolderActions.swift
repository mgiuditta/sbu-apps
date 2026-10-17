import SbuKit
import SwiftUI

/// The way to fill an empty inventory or folder, under its empty state: add an item and, at the top,
/// try the sample house, which goes with one delete. One button per row, as a `List` row keeps one tap.
struct EmptyFolderActions: View {
    let isTop: Bool
    let add: () -> Void
    let addSample: () -> Void

    var body: some View {
        Section {
            SbuButton("Aggiungi oggetto", action: add)
                .accessibilityIdentifier("addFirst")
            if isTop {
                SbuButton("Prova con un esempio", kind: .secondary, action: addSample)
                    .accessibilityIdentifier("addSample")
            }
        }
        .listRowInsets(EdgeInsets(top: SbuTheme.space1, leading: SbuTheme.space4, bottom: SbuTheme.space1, trailing: SbuTheme.space4))
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
    }
}

#Preview("Light") {
    List {
        EmptyFolderActions(isTop: true, add: {}, addSample: {})
    }
    .scrollContentBackground(.hidden)
    .background(SbuTheme.paper)
}

#Preview("Dark") {
    List {
        EmptyFolderActions(isTop: false, add: {}, addSample: {})
    }
    .scrollContentBackground(.hidden)
    .background(SbuTheme.paper)
    .preferredColorScheme(.dark)
}
