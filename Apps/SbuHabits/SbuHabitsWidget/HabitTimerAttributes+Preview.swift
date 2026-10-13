import Foundation

extension HabitTimerAttributes {
    /// "Leggere", 20 minutes, for the previews.
    static let preview = HabitTimerAttributes(habitID: UUID(), title: "Leggere", symbol: "book", duration: .seconds(20 * 60))
}

extension HabitTimerAttributes.ContentState {
    /// Running, with a little more than 18 minutes left.
    static var previewRunning: Self {
        Self(phase: .running(endsAt: .now.addingTimeInterval(18 * 60 + 56)))
    }

    /// Paused with 12 minutes and a half left.
    static let previewPaused = Self(phase: .paused(secondsLeft: 12 * 60 + 30))
}
