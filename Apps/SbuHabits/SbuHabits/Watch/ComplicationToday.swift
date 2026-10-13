/// The complication's numbers for today: the Serie piena, and how many of today's habits are
/// complete out of how many.
nonisolated struct ComplicationToday: Equatable, Sendable {
    let fullStreak: Int
    let done: Int
    let total: Int

    init(fullStreak: Int, done: Int, total: Int) {
        self.fullStreak = fullStreak
        self.done = done
        self.total = total
    }

    init(_ snapshot: WatchSnapshot) {
        fullStreak = snapshot.fullStreak
        done = snapshot.habits.count { snapshot.progress(of: $0).isComplete }
        total = snapshot.habits.count
    }
}
