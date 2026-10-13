import SwiftUI

/// Today on the watch, in numbers, for the screen's context line and the complication: the
/// Serie piena, and how many of today's habits to do are complete out of how many. An Abitudine
/// da evitare stays out: its day is not over until it ends.
nonisolated struct TodayTally: Equatable, Sendable {
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
        let toDo = snapshot.habits.map(snapshot.progress(of:)).filter { $0.limit == nil }
        done = toDo.count(where: \.isComplete)
        total = toDo.count
    }

    /// For VoiceOver: "12 giorni, 3 su 5 oggi".
    var spokenValue: Text {
        Text("\(fullStreak) giorni") + Text(verbatim: ", ") + Text("\(done) su \(total) oggi")
    }
}
