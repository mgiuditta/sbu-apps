extension WatchLink {
    /// The link over WatchConnectivity, following `model`: made once at launch, the background
    /// ones included, since a tap on the watch can wake the app.
    static func live(model: HabitsModel) -> WatchLink {
        let link = WatchLink(model: model, channel: WatchConnectivityChannel())
        let bridge = WatchSessionBridge()
        model.didUpdateForWatch = { link.publish() }
        // Lives as long as the app: one session for the whole process.
        Task {
            for await event in bridge.events {
                link.handle(event)
            }
        }
        bridge.activate()
        return link
    }
}
