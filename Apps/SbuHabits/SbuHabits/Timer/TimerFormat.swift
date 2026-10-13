import Foundation

/// How an Abitudine a tempo shows its length and the time left, in the user's locale.
nonisolated enum TimerFormat {
    /// A clock, "3:00" or "1:30:00": hours only for a countdown of an hour or more, so the
    /// figure keeps its shape for the whole countdown.
    static func clock(for duration: Duration) -> Duration.TimeFormatStyle {
        .time(pattern: duration >= .seconds(3_600) ? .hourMinuteSecond : .minuteSecond)
    }

    /// The length under the habit's title: "20 min", "1 h 30 min".
    static let length = Duration.UnitsFormatStyle(allowedUnits: [.hours, .minutes], width: .abbreviated)

    /// The time left in words, for VoiceOver: "2 minuti e 59 secondi".
    static let spoken = Duration.UnitsFormatStyle(allowedUnits: [.hours, .minutes, .seconds], width: .wide)
}
