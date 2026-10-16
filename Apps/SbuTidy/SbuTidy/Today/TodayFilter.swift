import Foundation

/// The filter on top of the to-do list, as Tody's: what is due now, or what comes next.
nonisolated enum TodayFilter: String, CaseIterable, Identifiable, Sendable {
    /// Due today or late.
    case toDo
    /// Not due yet, due within `upcomingDays`. Tody's "upcoming": what you could get ahead on.
    case upcoming

    /// How far ahead "In scadenza" looks: a week, the longest gap between two cleaning days.
    static let upcomingDays = 7

    var id: Self { self }

    var title: LocalizedStringResource {
        switch self {
        case .toDo: "Da fare"
        case .upcoming: "In scadenza"
        }
    }
}
