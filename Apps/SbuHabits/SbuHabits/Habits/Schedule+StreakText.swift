import Foundation

extension Schedule {
    /// A Serie of `count` in this schedule's unit: days, or weeks or months for a counted one.
    nonisolated func streakText(_ count: Int) -> LocalizedStringResource {
        switch period {
        case .week: "\(count) settimane"
        case .month: "\(count) mesi"
        case nil: "\(count) giorni"
        }
    }

    /// The same Serie, abbreviated for a row of the tool screen: "12 gg".
    nonisolated func shortStreakText(_ count: Int) -> LocalizedStringResource {
        switch period {
        case .week: "\(count) sett."
        case .month: "\(count) mesi"
        case nil: "\(count) gg"
        }
    }
}
