import Foundation

/// What the Live Activity of a countdown shows, worked out from its attributes and state so the
/// views only draw: the range the system counts down by itself while it runs, the ring's fill
/// and the time left once it stops, and when it goes stale.
nonisolated struct TimerActivityFace: Equatable, Sendable {
    let title: String
    let symbol: String
    /// The whole countdown, after the title.
    let duration: Duration
    let phase: HabitTimerAttributes.ContentState.Phase

    /// - Parameter isStale: Past the stale date a running countdown has reached its end, even
    ///   with the app still away: it reads done, as the notification at the end says.
    init(attributes: HabitTimerAttributes, state: HabitTimerAttributes.ContentState, isStale: Bool = false) {
        title = attributes.title
        duration = attributes.duration
        phase = if isStale, case .running = state.phase { .done } else { state.phase }
        // Done, the ring closes on the checkmark, as the home's does.
        symbol = phase == .done ? "checkmark" : attributes.symbol
    }

    var isRunning: Bool {
        if case .running = phase { true } else { false }
    }

    var isDone: Bool {
        phase == .done
    }

    /// While it runs, the dates the system counts between with `Text(timerInterval:)` and
    /// `ProgressView(timerInterval:)`: from when the whole countdown would have started, so the
    /// ring shows the time gone by out of the whole, also after a pause, to its end.
    var countdown: ClosedRange<Date>? {
        guard case .running(let endsAt) = phase else { return nil }
        return endsAt.addingTimeInterval(-totalSeconds)...endsAt
    }

    /// The time left while paused, rounded up to the second as the Timer shows it; `nil` while
    /// it runs, when the system counts it, and once done.
    var remaining: Duration? {
        guard case .paused(let left) = phase else { return nil }
        return .seconds(max(left, 0).rounded(.up))
    }

    /// How the time left reads while paused: hours only while an hour or more is left, as the
    /// system's own countdown does while it runs, so pausing never changes the figure's shape.
    var clock: Duration.TimeFormatStyle {
        TimerFormat.clock(for: remaining ?? duration)
    }

    /// The whole countdown after the title: "20:00".
    var length: Duration.TimeFormatStyle {
        TimerFormat.clock(for: duration)
    }

    /// How much of the countdown has gone by at `now`, from 0 to 1, for the ring.
    func progress(at now: Date) -> Double {
        guard totalSeconds > 0 else { return 1 }
        return min(max(1 - secondsLeft(at: now) / totalSeconds, 0), 1)
    }

    /// When a running countdown reaches its end: past it the activity reads done until the
    /// app comes back and ends it. A paused or done one never goes stale.
    var staleDate: Date? {
        if case .running(let endsAt) = phase { endsAt } else { nil }
    }

    private var totalSeconds: Double {
        Double(duration.components.seconds) + Double(duration.components.attoseconds) / 1e18
    }

    private func secondsLeft(at now: Date) -> Double {
        switch phase {
        case .running(let endsAt): max(endsAt.timeIntervalSince(now), 0)
        case .paused(let left): min(max(left, 0), totalSeconds)
        case .done: 0
        }
    }
}
