import Foundation

/// A file chosen with Importa, checked and ready to replace the current data.
nonisolated struct HabitsImport: Identifiable, Sendable {
    let id = UUID()
    let file: HabitsFile

    /// The day the oldest habit started, or `nil` for a file without habits.
    var firstDay: LogicalDay? {
        file.habits.map(\.createdOn).min()
    }

    /// Checks `data`: not empty, a Sbu Habits file, from this version of the app or an older one.
    init(data: Data) throws(Failure) {
        guard data.isEmpty == false else { throw .empty }
        let decoder = JSONDecoder()
        // The version first: a newer file may not decode, and should say why.
        guard let version = try? decoder.decode(Header.self, from: data).version else { throw .damaged }
        guard version <= HabitsFile.currentVersion else { throw .newerVersion }
        guard var file = try? decoder.decode(HabitsFile.self, from: data), file.habits.allSatisfy(Self.isPlausible) else { throw .damaged }
        file.startHour = Habit.clamp(file.startHour, to: HabitsFile.startHourRange)
        self.file = file
    }

    /// Reads the file the document picker returned, which lives outside the app's sandbox.
    init(contentsOf url: URL) throws(Failure) {
        let isScoped = url.startAccessingSecurityScopedResource()
        defer {
            if isScoped {
                url.stopAccessingSecurityScopedResource()
            }
        }
        guard let data = try? Data(contentsOf: url) else { throw .unreadable }
        try self.init(data: data)
    }

    /// The first day a habit can start: 1 January 2000. Streaks walk every day from a habit's
    /// start, so a file claiming a start far in the past would hang the app on every launch.
    static let earliestDay = LogicalDay(ordinal: 10_957)
    /// The last day a file can name, 1 January 2100: far enough for any clock, short of overflow.
    static let latestDay = LogicalDay(ordinal: 47_482)
    /// Most times a day a log can hold, far above the form's ranges, short of overflow.
    static let maxCount = 10_000
    /// Most edits a habit can keep: each day reads them all, so a crafted list would slow every launch.
    static let maxEdits = 1_000

    /// Values the form could have produced: a file edited by hand or crafted is refused, not
    /// trusted, since it replaces everything and is read again on every launch.
    static func isPlausible(_ habit: Habit) -> Bool {
        let schedules = [habit.schedule] + habit.earlier.map(\.schedule)
        let oneDays = schedules.compactMap { schedule in
            if case .oneDay(let day) = schedule { day } else { nil }
        }
        let days = [habit.createdOn] + habit.earlier.map(\.until) + habit.log.keys + habit.skipped + habit.markHours.keys + habit.notes.keys + oneDays
        let times = [habit.timesPerDay] + habit.earlier.map(\.timesPerDay)
        let limits = ([habit.limit] + habit.earlier.map(\.limit)).compactMap { $0 }
        let untils = habit.earlier.map(\.until)
        return days.allSatisfy { (earliestDay...latestDay).contains($0) }
            && habit.earlier.count <= maxEdits
            // At most one edit a day, after the start, oldest first: the order `schedule(on:)` relies on.
            && zip([habit.createdOn] + untils, untils).allSatisfy { $0 < $1 }
            && habit.title.count <= Habit.maxTitleLength
            && times.allSatisfy(Habit.timesPerDayRange.contains)
            && limits.allSatisfy(Habit.limitRange.contains)
            // A Salute goal the form offers (NaN never is), and only on a habit to do.
            && habit.health.map { $0.measure.goalRange.contains($0.goal) && habit.limit == nil } ?? true
            // A length the form offers, only on a habit to do that Salute does not mark.
            && habit.timerMinutes.map { Habit.timerMinutesRange.contains($0) && habit.limit == nil && habit.health == nil } ?? true
            && habit.log.values.allSatisfy { (0...maxCount).contains($0) }
            // Never more hours than marks: days from before hours existed may have fewer.
            && habit.markHours.allSatisfy { day, hours in hours.count <= habit.count(on: day) && hours.allSatisfy((0..<24).contains) }
            // Notes the editor could have saved: trimmed, never blank, never too long.
            && habit.notes.values.allSatisfy(DailyNote.isPlausible)
            && habit.reminders.allSatisfy { (0..<24).contains($0.hour) && (0..<60).contains($0.minute) }
            // Orari automatici replace the times, and an Abitudine da evitare has no reminders.
            && (habit.remindsAutomatically == false || (habit.reminders.isEmpty && habit.limit == nil))
            // The word when Salute marks it, only on a habit Salute marks.
            && (habit.notificationStyle.announcesHealthMark == false || habit.health != nil)
            && schedules.allSatisfy { schedule in
                switch schedule {
                case .everyDay: true
                case .weekdays(let days): days.isEmpty == false && days.isSubset(of: 1...7)
                case .timesPerWeek(let times): Schedule.timesPerWeekRange.contains(times)
                // Counted in months or on one day only: never with a Limite.
                case .timesPerMonth(let times): Schedule.timesPerMonthRange.contains(times) && habit.limit == nil
                case .oneDay: habit.limit == nil
                }
            }
    }

    private struct Header: Decodable {
        let version: Int
    }
}
