import Foundation

/// When the search's Live Activity starts, updates and ends.
///
/// It starts with the finder, updates at most once a second and only when what it shows
/// changes (at once when the device falls silent or is heard again), and ends when the finder
/// closes or at the "found it" moment, which it shows before going.
nonisolated struct SearchActivityPlan: Equatable, Sendable {
    typealias State = SearchActivityAttributes.ContentState

    enum Step: Equatable, Sendable {
        case start(SearchActivityAttributes, State)
        case update(State)
        /// Ends the activity; with a final state it stays a moment to show it.
        case end(State?)
        case none
    }

    /// The shortest gap between two updates.
    static let minimumInterval: TimeInterval = 1

    private(set) var isActive = false
    private var lastState: State?
    private var lastSent: Date?

    mutating func begin(_ attributes: SearchActivityAttributes, state: State, at now: Date) -> Step {
        isActive = true
        lastState = state
        lastSent = now
        return .start(attributes, state)
    }

    mutating func follow(_ state: State, at now: Date) -> Step {
        guard isActive, state != lastState else { return .none }
        let silenceChanged = state.isLost != lastState?.isLost
        if !silenceChanged, let lastSent, now.timeIntervalSince(lastSent) < Self.minimumInterval {
            return .none
        }
        lastState = state
        lastSent = now
        return .update(state)
    }

    /// The "found it" moment, with the state of that moment: an update skipped by the
    /// one-second gap must not leave an older figure on the final card.
    mutating func found(_ current: State) -> Step {
        guard isActive else { return .none }
        var state = current
        state.isFound = true
        isActive = false
        lastState = nil
        return .end(state)
    }

    /// The finder closed.
    mutating func close() -> Step {
        guard isActive else { return .none }
        isActive = false
        lastState = nil
        return .end(nil)
    }
}
