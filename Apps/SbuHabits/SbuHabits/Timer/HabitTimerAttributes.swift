import ActivityKit
import Foundation

/// The Live Activity of the countdown of an Abitudine a tempo, on the Lock Screen and in the
/// Dynamic Island: what stays the same for its whole life. One at a time, as the timer.
nonisolated struct HabitTimerAttributes: ActivityAttributes, Hashable, Sendable {
    /// What changes while it runs: running to an end date, paused with the time left, or done.
    nonisolated struct ContentState: Codable, Hashable, Sendable {
        nonisolated enum Phase: Codable, Hashable, Sendable {
            case running(endsAt: Date)
            /// Seconds left, exact, as the timer keeps them.
            case paused(secondsLeft: Double)
            /// Ran to its end or marked done: the activity says "Fatta" before it goes.
            case done
        }

        var phase: Phase

        /// The state of `timer` as it is now.
        init(timer: HabitTimer) {
            phase = switch timer.state {
            case .running(let endsAt): .running(endsAt: endsAt)
            case .paused(let secondsLeft): .paused(secondsLeft: secondsLeft)
            }
        }

        init(phase: Phase) {
            self.phase = phase
        }

        static let done = ContentState(phase: .done)
    }

    /// The habit, so the buttons pause and resume this countdown and no other.
    let habitID: UUID
    let title: String
    let symbol: String
    /// The whole countdown, as the habit asks for it.
    let duration: Duration

    init(habitID: UUID, title: String, symbol: String, duration: Duration) {
        self.habitID = habitID
        self.title = title
        self.symbol = symbol
        self.duration = duration
    }

    /// The activity of `timer`, with its habit's symbol.
    init(timer: HabitTimer, symbol: String) {
        self.init(habitID: timer.habitID, title: timer.title, symbol: symbol, duration: timer.duration)
    }
}
