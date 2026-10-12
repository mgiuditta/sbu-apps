import Foundation

/// Minutes of consapevolezza in a day, from the sessions Salute keeps. A session across the start
/// of the day counts only for its part inside it, and sessions logged twice (iPhone and Watch)
/// count once.
nonisolated enum MindfulMinutes {
    static func total(of sessions: [DateInterval], within day: DateInterval) -> Double {
        let inside = sessions.compactMap { $0.intersection(with: day) }.sorted { $0.start < $1.start }
        var seconds: TimeInterval = 0
        var covered: Date = day.start
        for session in inside {
            let start = max(session.start, covered)
            if session.end > start {
                seconds += session.end.timeIntervalSince(start)
                covered = session.end
            }
        }
        return seconds / 60
    }
}
