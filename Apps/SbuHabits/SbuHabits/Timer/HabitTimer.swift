import Foundation

/// The countdown of an Abitudine a tempo: an end date while it runs, the time left while it is
/// paused. Never a ticking counter, so it holds through the background, the lock and the app
/// being closed. One at a time; cancelling or finishing it throws it away.
nonisolated struct HabitTimer: Hashable, Codable, Sendable {
    nonisolated enum State: Hashable, Codable, Sendable {
        case running(endsAt: Date)
        /// Seconds left, exact: a pause never rounds the time away.
        case paused(secondsLeft: Double)
    }

    let habitID: UUID
    /// The habit's title, for the notification at the end.
    let title: String
    /// The logical day it was started on: the day its end marks done, even past midnight.
    let day: LogicalDay
    /// The whole countdown, as the habit asks for it.
    let duration: Duration
    private(set) var state: State

    /// Starts a countdown of `duration` at `now`.
    init(habitID: UUID, title: String, day: LogicalDay, duration: Duration, now: Date) {
        self.habitID = habitID
        self.title = title
        self.day = day
        self.duration = duration
        state = .running(endsAt: now.addingTimeInterval(Self.seconds(duration)))
    }

    /// Starts the habit's countdown at `now`, or `nil` for a habit that is not timed.
    init?(habit: Habit, day: LogicalDay, now: Date) {
        guard let duration = habit.timerDuration else { return nil }
        self.init(habitID: habit.id, title: habit.title, day: day, duration: duration, now: now)
    }

    var isRunning: Bool {
        if case .running = state { true } else { false }
    }

    /// When it ends, only while it runs: a paused countdown has no end yet.
    var endDate: Date? {
        if case .running(let endsAt) = state { endsAt } else { nil }
    }

    /// Time left at `now`, rounded up to the second as the screen shows it: it reads 3:00 at the
    /// start and 0:00 only once it has ended.
    func remaining(at now: Date) -> Duration {
        .seconds(secondsLeft(at: now).rounded(.up))
    }

    /// How much of the countdown has gone by at `now`, from 0 to 1, for the ring.
    func progress(at now: Date) -> Double {
        let total = Self.seconds(duration)
        guard total > 0 else { return 1 }
        return min(max(1 - secondsLeft(at: now) / total, 0), 1)
    }

    /// Whether it ran to its end by `now`. A paused countdown never ends on its own.
    func isFinished(at now: Date) -> Bool {
        guard let endDate else { return false }
        return now >= endDate
    }

    /// Stops the clock at `now`, keeping the time left.
    mutating func pause(at now: Date) {
        guard isRunning else { return }
        state = .paused(secondsLeft: secondsLeft(at: now))
    }

    /// Starts the clock again at `now` for the time that was left.
    mutating func resume(at now: Date) {
        guard case .paused(let left) = state else { return }
        state = .running(endsAt: now.addingTimeInterval(left))
    }

    private func secondsLeft(at now: Date) -> Double {
        switch state {
        case .running(let endsAt): max(endsAt.timeIntervalSince(now), 0)
        case .paused(let left): left
        }
    }

    private static func seconds(_ duration: Duration) -> Double {
        Double(duration.components.seconds) + Double(duration.components.attoseconds) / 1e18
    }
}
