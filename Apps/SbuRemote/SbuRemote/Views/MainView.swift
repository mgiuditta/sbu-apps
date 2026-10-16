import SbuKit
import SwiftUI

/// The tool screen: the remote of the current TV, or the way to add the first one.
struct MainView: View {
    let session: RemoteSession

    @Environment(\.scenePhase) private var scenePhase
    @State private var network = NetworkMonitor()

    @State private var isAddingTV = false
    @State private var isTyping = false
    @State private var isSpeaking = false
    @State private var voice = VoiceSearch()
    @State private var pins = PinnedAppsStore()
    @State private var isPickingApp = false

    var body: some View {
        Group {
            if let tv = session.tv {
                RemoteView(session: session, tvName: tv.name, pinnedApps: pins.pins.apps(for: tv.id))
            } else {
                NoTVView(onAdd: showAddTV)
            }
        }
        .toolbar {
            if session.tv != nil {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Tastiera", systemImage: "keyboard", action: showKeyboard)
                        .disabled(!session.status.acceptsKeys)
                }
                // Only where this language is recognized on the iPhone: otherwise no button.
                if voice.isAvailable {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Cerca con la voce", systemImage: "mic", action: showVoice)
                            .disabled(!session.status.acceptsKeys)
                    }
                }
            }
            if session.tv != nil {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("App", systemImage: "square.grid.2x2", action: showApps)
                        .disabled(!session.status.acceptsKeys)
                }
            }
            if session.tv != nil {
                ToolbarItem(placement: .principal) {
                    TVPickerMenu(session: session, onAdd: showAddTV)
                }
            }
        }
        .task(id: session.tv?.id) {
            await session.connect()
        }
        .onChange(of: scenePhase) { _, phase in
            sceneChanged(to: phase)
        }
        .onChange(of: network.generation) {
            Task { await session.handle(.networkChanged(isOnLocalNetwork: network.isOnLocalNetwork)) }
        }
        .sheet(isPresented: $isAddingTV) {
            AddTVView(onPaired: add)
        }
        .sheet(isPresented: $isTyping) {
            KeyboardSheet(session: session)
        }
        .sheet(isPresented: $isPickingApp) {
            AppsSheet(session: session, pins: pins)
        }
        .sheet(isPresented: $isSpeaking) {
            VoiceSheet(session: session, voice: voice)
        }
    }

    private func showAddTV() {
        isAddingTV = true
    }

    private func sceneChanged(to phase: ScenePhase) {
        switch phase {
        case .active: Task { await session.handle(.becameActive) }
        case .background: Task { await session.handle(.wentToBackground) }
        default: break
        }
    }

    private func showKeyboard() {
        isTyping = true
    }

    private func showApps() {
        isPickingApp = true
    }

    private func showVoice() {
        isSpeaking = true
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
