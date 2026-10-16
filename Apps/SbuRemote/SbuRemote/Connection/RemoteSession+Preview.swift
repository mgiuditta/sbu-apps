#if DEBUG
import Foundation

extension RemoteSession {
    /// A session with the demo TV, connected, for previews.
    static var preview: RemoteSession {
        let defaults = UserDefaults(suiteName: "dev.sbu.remote.preview") ?? .standard
        defaults.removeObject(forKey: TVStore.key)
        let store = TVStore(defaults: defaults)
        store.add(DemoTVClient.demoTV)
        let session = RemoteSession(store: store, makeClient: DemoTVClient.init(tv:))
        Task { await session.connect() }
        return session
    }
}
#endif
