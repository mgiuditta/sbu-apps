import Foundation
import Observation

/// Which date the screen shows: now, or a day picked from the calendar.
@Observable
final class MoonModel {
    /// The dates the calendar offers: the ΔT and phase formulas hold well across them.
    static let dateRange: ClosedRange<Date> = {
        let calendar = Calendar(identifier: .gregorian)
        let start = calendar.date(from: DateComponents(year: 1900, month: 1, day: 1)) ?? .distantPast
        let end = calendar.date(from: DateComponents(year: 2100, month: 12, day: 31)) ?? .distantFuture
        return start...end
    }()

    /// A waxing gibbous moon, for the App Store screenshots.
    private static let snapshotDate = Date(timeIntervalSince1970: 1_705_816_800) // 2024-01-21 06:00 UTC

    /// A date picked by the user, or `nil` to follow now.
    private(set) var pickedDate: Date?

    /// Stands in for now in fastlane snapshot, so the screenshots always show the same moon.
    @ObservationIgnored private let fixedNow: Date?

    var isShowingToday: Bool { pickedDate == nil }

    init(defaults: UserDefaults = .standard) {
        fixedNow = defaults.bool(forKey: "FASTLANE_SNAPSHOT") ? Self.snapshotDate : nil
    }

    /// The instant to show, given the current time.
    func date(now: Date) -> Date {
        pickedDate ?? fixedNow ?? now
    }

    /// Shows a date; a date in the same day as `now` goes back to following now.
    func show(_ date: Date, now: Date = .now, calendar: Calendar = .current) {
        pickedDate = calendar.isDate(date, inSameDayAs: fixedNow ?? now) ? nil : date
    }

    /// Moves the date shown by whole days, at the same time of day, within `dateRange`.
    func showDay(byAdding days: Int, now: Date = .now, calendar: Calendar = .current) {
        let shown = date(now: now)
        guard let moved = calendar.date(byAdding: .day, value: days, to: shown),
              Self.dateRange.contains(moved)
        else { return }
        show(moved, now: now, calendar: calendar)
    }

    func showToday() {
        pickedDate = nil
    }
}
