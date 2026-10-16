import SwiftUI

@main
struct SbuRemoteApp: App {
    @State private var session = Self.makeSession()

    var body: some Scene {
        WindowGroup {
            RootView(session: session)
        }
    }

    private static func makeSession() -> RemoteSession {
        #if DEBUG
        if DemoTVClient.isEnabled {
            let defaults = UserDefaults(suiteName: "dev.sbu.remote.demo") ?? .standard
            defaults.removeObject(forKey: TVStore.key)
            let store = TVStore(defaults: defaults)
            store.add(DemoTVClient.demoTV)
            return RemoteSession(store: store, makeClient: DemoTVClient.init(tv:))
        }
        #endif
        return RemoteSession(store: TVStore())
    }
}
