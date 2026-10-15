import SbuKit
import SwiftUI

/// The chat's actions: who you are, its name, deleting it.
struct ChatMenu: View {
    let chooseOwner: () -> Void
    let rename: () -> Void
    let delete: () -> Void

    var body: some View {
        Menu {
            Button("Chi sei?", systemImage: "person.crop.circle", action: chooseOwner)
            Button("Rinomina", systemImage: "pencil", action: rename)
            Button("Elimina la chat", systemImage: "trash", role: .destructive, action: delete)
        } label: {
            Label("Azioni della chat", systemImage: "ellipsis.circle")
        }
        // In ink, like the gear: the accent belongs to the figure's full stop.
        .tint(SbuTheme.ink)
    }
}
