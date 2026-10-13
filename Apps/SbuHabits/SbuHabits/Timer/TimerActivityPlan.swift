import Foundation

/// What to do with the Live Activities on the device for an update of the countdown: which go at
/// once, which end reading "Fatta", which follow the new state, and whether a new one starts.
/// One countdown at a time, so at most one activity is kept.
nonisolated struct TimerActivityPlan: Equatable, Sendable {
    /// An activity still on the device, by its id and its habit.
    nonisolated struct Running: Equatable, Sendable {
        let id: String
        let habitID: UUID
    }

    /// How long a countdown that ended done stays on the Lock Screen, reading "Fatta".
    static let doneLinger: TimeInterval = 60

    /// Activities that go at once.
    private(set) var dismissed: [String] = []
    /// Activities that end reading "Fatta", then go after `doneLinger`.
    private(set) var finished: [String] = []
    /// Activities that follow `state`.
    private(set) var followed: [String] = []
    /// The state for the followed or the new activity.
    private(set) var state: HabitTimerAttributes.ContentState?
    /// A new activity to start, with `state`.
    private(set) var started: HabitTimerAttributes?

    init(update: TimerActivityUpdate, running: [Running]) {
        let ids = running.map(\.id)
        switch update {
        case .start(let timer, let symbol):
            dismissed = ids
            state = HabitTimerAttributes.ContentState(timer: timer)
            started = HabitTimerAttributes(timer: timer, symbol: symbol)
        case .follow(let timer):
            let kept = running.first { $0.habitID == timer.habitID }?.id
            followed = kept.map { [$0] } ?? []
            dismissed = ids.filter { $0 != kept }
            state = kept == nil ? nil : HabitTimerAttributes.ContentState(timer: timer)
        case .end(let isDone):
            if isDone {
                finished = ids
            } else {
                dismissed = ids
            }
        }
    }
}
