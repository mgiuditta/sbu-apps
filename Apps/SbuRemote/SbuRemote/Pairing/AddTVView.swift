import SbuKit
import SwiftUI

/// The sheet that adds a TV: the TVs on the Wi-Fi, then pairing the one the user picks.
struct AddTVView: View {
    let onPaired: (SavedTV) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var discovery = TVDiscovery()
    @State private var candidate: TVCandidate?

    var body: some View {
        NavigationStack {
            DiscoveryView(discovery: discovery, onPick: pick)
                .navigationTitle("Aggiungi una TV")
                .navigationBarTitleDisplayMode(.inline)
                .navigationDestination(item: $candidate) { candidate in
                    PairingView(candidate: candidate, onPaired: paired)
                }
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Annulla", action: close)
                    }
                }
        }
    }

    private func pick(_ candidate: TVCandidate) {
        self.candidate = candidate
    }

    private func paired(_ tv: SavedTV) {
        onPaired(tv)
        dismiss()
    }

    private func close() {
        dismiss()
    }
}

#Preview("Light") {
    AddTVView { _ in }
        .tint(SbuTheme.accentRemote)
}

#Preview("Dark") {
    AddTVView { _ in }
        .tint(SbuTheme.accentRemote)
        .preferredColorScheme(.dark)
}
