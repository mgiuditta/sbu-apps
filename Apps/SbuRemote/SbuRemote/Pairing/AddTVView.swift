import SbuKit
import SwiftUI

/// The sheet that adds a TV: the TVs on the Wi-Fi, then pairing the one the user picks.
/// Once paired, it closes when the pairing screen's Closure ends.
struct AddTVView: View {
    let onPaired: (SavedTV) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var discovery = TVDiscovery()
    @State private var candidate: TVCandidate?
    @State private var isPaired = false

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
        .task(id: isPaired) {
            guard isPaired else { return }
            try? await Task.sleep(for: .seconds(SbuTheme.closureDuration))
            guard !Task.isCancelled else { return }
            dismiss()
        }
    }

    private func pick(_ candidate: TVCandidate) {
        self.candidate = candidate
    }

    private func paired(_ tv: SavedTV) {
        onPaired(tv)
        isPaired = true
    }

    private func close() {
        dismiss()
    }
}

#Preview("Light") {
    AddTVView { _ in }
        .tint(SbuTheme.ink)
}

#Preview("Dark") {
    AddTVView { _ in }
        .tint(SbuTheme.ink)
        .preferredColorScheme(.dark)
}
