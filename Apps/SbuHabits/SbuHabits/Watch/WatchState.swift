/// What the Apple Watch keeps between launches: the last grid from the iPhone, and the taps sent
/// since that the iPhone has not confirmed yet.
///
/// The grid shown is the iPhone's with those taps counted, so a tap shows at once, offline too,
/// and a grid sent before a tap arrived never takes it back on screen.
nonisolated struct WatchState: Codable, Equatable, Sendable {
    private(set) var snapshot: WatchSnapshot?
    /// Sent, oldest first, and not yet in the snapshot's `applied`.
    private(set) var pending: [WatchAction] = []

    init(snapshot: WatchSnapshot? = nil, pending: [WatchAction] = []) {
        self.snapshot = snapshot
        self.pending = pending
    }

    /// The iPhone's grid with the pending taps of its day counted.
    var shown: WatchSnapshot? {
        guard let snapshot else { return nil }
        return pending.filter { $0.day == snapshot.today }.reduce(snapshot) { $0.applying($1) }
    }

    /// Takes a new grid from the iPhone. A tap it lists as applied is no longer pending; nor is a
    /// tap of a day before its own, which the grid no longer shows.
    mutating func receive(_ snapshot: WatchSnapshot) {
        self.snapshot = snapshot
        let applied = Set(snapshot.applied)
        pending.removeAll { applied.contains($0.id) || $0.day < snapshot.today }
    }

    /// Keeps a tap until the iPhone confirms it.
    mutating func add(_ action: WatchAction) {
        pending.append(action)
    }
}
