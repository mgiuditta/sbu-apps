@testable import SbuHabits

/// The Apple Watch's end of the link, in memory: every grid the iPhone sent, oldest first.
final class FakeWatchChannel: WatchChannel {
    private(set) var sent: [WatchSnapshot] = []

    func send(_ snapshot: WatchSnapshot) {
        sent.append(snapshot)
    }
}
