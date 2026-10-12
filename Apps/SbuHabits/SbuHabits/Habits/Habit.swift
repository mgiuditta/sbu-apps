import Foundation

/// Something the user wants to do every day, with its log of the days it was done.
nonisolated struct Habit: Identifiable, Hashable, Codable, Sendable {
    /// Longest title the form accepts, so it fits a grid cell.
    static let maxTitleLength = 30

    let id: UUID
    var title: String
    /// SF Symbol name, one of `HabitSymbol.all`.
    var symbol: String
    /// The first day the habit counts: no day before it enters a Serie.
    let createdOn: LogicalDay
    /// How many times it was done on each logical day; missing days are zero.
    var log: [LogicalDay: Int] = [:]

    init(id: UUID = UUID(), title: String, symbol: String, createdOn: LogicalDay) {
        self.id = id
        self.title = title
        self.symbol = symbol
        self.createdOn = createdOn
    }

    func isDone(on day: LogicalDay) -> Bool {
        log[day, default: 0] > 0
    }
}
