import Foundation

/// The Sudoku of the day: the same puzzle for everyone, from a seed that is the date in UTC.
nonisolated enum DailyPuzzle {
    static let difficulty = Difficulty.hard

    /// Midnight UTC of the day `date` falls in.
    static func day(of date: Date) -> Date {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = .gmt
        return calendar.startOfDay(for: date)
    }

    static func puzzle(for day: Date) -> Puzzle {
        Puzzle(difficulty: difficulty, seed: UInt64(max(day.timeIntervalSince1970, 1)))
    }
}
