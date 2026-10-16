import SbuKit
import SwiftUI

/// The tool screen: the remote of the current TV, or the way to add the first one.
struct MainView: View {
    let session: RemoteSession

    @State private var isAddingTV = false

    var body: some View {
        Group {
            if let tv = session.tv {
                RemoteView(session: session, tvName: tv.name)
            } else {
                NoTVView(onAdd: showAddTV)
            }
        }
        .toolbar {
            if let tv = session.tv {
                ToolbarItem(placement: .principal) {
                    Text(tv.name)
                        .font(SbuTheme.headline)
                        .foregroundStyle(SbuTheme.ink)
                        .accessibilityAddTraits(.isHeader)
                }
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
