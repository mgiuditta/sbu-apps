import SbuKit
import SwiftUI

/// The tool screen: the remote of the current TV, or the way to add the first one.
struct MainView: View {
    @State private var isAddingTV = false
    @State private var discovery = TVDiscovery()

    var body: some View {
        NoTVView(onAdd: showAddTV)
            .sheet(isPresented: $isAddingTV) {
                NavigationStack {
                    DiscoveryView(discovery: discovery) { _ in
                        isAddingTV = false
                    }
                    .navigationTitle("Aggiungi una TV")
                    .navigationBarTitleDisplayMode(.inline)
                }
            }
    }

    private func showAddTV() {
        isAddingTV = true
    }
}

#Preview("Light") {
    NavigationStack {
        MainView()
    }
    .tint(SbuTheme.accentRemote)
}

#Preview("Dark") {
    NavigationStack {
        MainView()
    }
    .tint(SbuTheme.accentRemote)
    .preferredColorScheme(.dark)
}
