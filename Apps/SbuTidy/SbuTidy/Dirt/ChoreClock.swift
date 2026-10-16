import Foundation

/// Where a chore's cycle stands: when it was last done, and how long it has been paused since.
///
/// Dirt grows from `lastDone`; time spent paused does not count, as in Tody, so a chore paused
/// for a holiday comes back exactly as dirty as it was.
nonisolated struct ChoreClock: Equatable, Sendable {
    /// The start of the current cycle: the latest completion, or when you said it was last done.
    var lastDone: Date
    /// Set while the chore is paused.
    var pausedAt: Date?
    /// Time paused since `lastDone`, for pauses already ended.
    var pausedSeconds: TimeInterval = 0

    var isPaused: Bool { pausedAt != nil }

    /// Time paused since `lastDone` up to `now`, the current pause included.
    func pausedTime(at now: Date) -> TimeInterval {
        let current = pausedAt.map { max(now.timeIntervalSince($0), 0) } ?? 0
        return max(pausedSeconds, 0) + current
    }

    /// Time that counts towards dirt: since `lastDone`, without pauses. Never negative, also
    /// when `lastDone` is in the future because the clock of the device moved back.
    func elapsed(at now: Date) -> TimeInterval {
        max(now.timeIntervalSince(lastDone) - pausedTime(at: now), 0)
    }

    /// Records a completion. A later one starts a new cycle and ends any pause; an earlier one
    /// only goes in the history. A date in the future counts as now.
    mutating func markDone(at date: Date, now: Date) {
        let date = min(date, now)
        guard date >= lastDone else { return }
        lastDone = date
        pausedAt = nil
        pausedSeconds = 0
    }

    mutating func pause(at now: Date) {
        guard pausedAt == nil else { return }
        pausedAt = max(now, lastDone)
    }

    mutating func resume(at now: Date) {
        guard let pausedAt else { return }
        pausedSeconds = max(pausedSeconds, 0) + max(now.timeIntervalSince(pausedAt), 0)
        self.pausedAt = nil
    }

    /// After a completion was removed from the history: the cycle starts again from the
    /// latest one left, or from `start` when none is left. Removing an older entry changes
    /// nothing; removing the latest drops the pauses, which belonged to the cycle it started.
    mutating func restart(from completions: [Date], start: Date) {
        let latest = completions.max() ?? start
        guard latest != lastDone else { return }
        lastDone = latest
        pausedSeconds = 0
        if let pausedAt, pausedAt < lastDone { self.pausedAt = lastDone }
    }
}
