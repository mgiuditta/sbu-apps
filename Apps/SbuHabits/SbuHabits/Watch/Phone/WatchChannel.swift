/// Where the iPhone sends today's grid for the Apple Watch: WatchConnectivity in the app, a fake
/// in tests.
protocol WatchChannel {
    /// Replaces the grid the watch has, now or as soon as it can receive it.
    func send(_ snapshot: WatchSnapshot)
}
