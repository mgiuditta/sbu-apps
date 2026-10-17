import Foundation

/// A change of the countdown that its Live Activity follows, as `HabitsModel` reports it.
nonisolated enum TimerActivityUpdate: Hashable, Sendable {
    /// A countdown started: its activity replaces any other.
    case start(HabitTimer, symbol: String)
    /// The saved countdown, just paused or resumed, or found at launch: its activity follows it
    /// and any other ends. It never starts one: an activity swiped away stays away.
    case follow(HabitTimer)
    /// No countdown any more. Done, it sets its full stop for a moment; cancelled, it goes at once.
    case end(isDone: Bool)
}
