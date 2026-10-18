import Foundation

/// The two ways to play: the Partita del giorno, the same for everyone, or a free game.
nonisolated enum GameMode: String, Codable, CaseIterable, Sendable {
    case daily
    case free

    /// The seed of the Partita del giorno of `date`: the calendar day as `yyyymmdd`.
    static func dailySeed(for date: Date, calendar: Calendar = .current) -> UInt64 {
        let day = calendar.dateComponents([.year, .month, .day], from: date)
        return UInt64((day.year ?? 0) * 10_000 + (day.month ?? 0) * 100 + (day.day ?? 0))
    }
}
