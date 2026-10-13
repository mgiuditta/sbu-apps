import Foundation

/// The kinds of schedule the form's Giorni screen offers, one per case of `Schedule`.
nonisolated enum ScheduleKind: CaseIterable, Hashable, Sendable {
    case everyDay, weekdays, timesPerWeek, timesPerMonth, oneDay

    init(_ schedule: Schedule) {
        self = switch schedule {
        case .everyDay: .everyDay
        case .weekdays: .weekdays
        case .timesPerWeek: .timesPerWeek
        case .timesPerMonth: .timesPerMonth
        case .oneDay: .oneDay
        }
    }

    var title: LocalizedStringResource {
        switch self {
        case .everyDay: "Ogni giorno"
        case .weekdays: "Giorni della settimana"
        case .timesPerWeek: "Volte a settimana"
        case .timesPerMonth: "Volte al mese"
        case .oneDay: "Un giorno solo"
        }
    }

    /// Counted in weeks or months: done once a day, the count is the days.
    var isCounted: Bool {
        self == .timesPerWeek || self == .timesPerMonth
    }

    /// An Abitudine da evitare is never counted in weeks or months, nor an Attività di un giorno.
    static func choices(for kind: HabitKind) -> [ScheduleKind] {
        kind == .toAvoid ? [.everyDay, .weekdays] : allCases
    }
}
