import SbuKit
import SwiftUI

/// The tool screen: the remote of the current TV, or the way to add the first one.
struct MainView: View {
    let session: RemoteSession

    @State private var isAddingTV = false

    var body: some View {
        Group {
            if let tv = session.tv {
                ConnectionStatusView(tvName: tv.name, status: session.status, onRetry: retry)
            } else {
                NoTVView(onAdd: showAddTV)
            }
        }
        .task(id: session.tv?.id) {
            await session.connect()
        }
        .sheet(isPresented: $isAddingTV) {
            AddTVView(onPaired: add)
        }
    }

    private func showAddTV() {
        isAddingTV = true
    }

    private func add(_ tv: SavedTV) {
        Task { await session.add(tv) }
    }

    private func retry() {
        Task { await session.connect() }
    }
}

#Preview("Light") {
    NavigationStack {
        MainView(session: RemoteSession(store: TVStore(defaults: UserDefaults(suiteName: "preview") ?? .standard)))
    }
    .tint(SbuTheme.accentRemote)
}

#Preview("Dark") {
    NavigationStack {
        MainView(session: RemoteSession(store: TVStore(defaults: UserDefaults(suiteName: "preview") ?? .standard)))
    }
    .tint(SbuTheme.accentRemote)
    .preferredColorScheme(.dark)
}
