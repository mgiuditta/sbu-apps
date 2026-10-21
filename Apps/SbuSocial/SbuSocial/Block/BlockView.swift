import SwiftUI

/// The native apps under the Shield, and Modalità post.
struct BlockView: View {
    var body: some View {
        TabScreen(title: "Blocco", sentence: "Scegli le app da schermare: le apri qui, senza video brevi.")
    }
}

#Preview("Light") {
    BlockView()
}

#Preview("Dark") {
    BlockView()
        .preferredColorScheme(.dark)
}
