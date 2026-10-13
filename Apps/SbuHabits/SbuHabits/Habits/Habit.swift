import Foundation

/// Something the user wants to do on some days, once or several times, with its log of the days it was done;
/// or, for an Abitudine da evitare, something to stay within a Limite of, with the times the user gave in.
nonisolated struct Habit: Identifiable, Hashable, Codable, Sendable {
    /// Longest title the form accepts, so it fits a grid cell.
    static let maxTitleLength = 30
    /// The range the form offers for times per day.
    static let timesPerDayRange = 1...20
    /// The range the form offers for the Limite: 0 is "never".
    static let limitRange = 0...20
    /// The lengths, in minutes, the form offers for the countdown of an Abitudine a tempo.
    static let timerMinutesRange = 1...180

    let id: UUID
    var title: String
    /// SF Symbol name, one of `HabitSymbol.all`.
    var symbol: String
    /// How many times a day it must be done: 1 for a yes/no habit, 8 for eight glasses of water.
    /// Today's value; past days use `timesPerDay(on:)`.
    private(set) var timesPerDay: Int
    /// Today's schedule; past days use `schedule(on:)`.
    private(set) var schedule: Schedule
    /// The Limite of an Abitudine da evitare, `nil` for a habit to do; the kind never changes.
    /// Today's value; past days use `limit(on:)`.
    private(set) var limit: Int?
    /// Settings replaced by edits, oldest first.
    private(set) var earlier: [HabitSettings] = []
    /// The first day the habit counts: no day before it enters a Serie.
    let createdOn: LogicalDay
    /// How many times it was done on each logical day; missing days are zero.
    var log: [LogicalDay: Int] = [:]
    /// The hour of the day, 0 to 23 on the clock where it happened, of each time marked on a
    /// logical day, oldest first: a mark at 01:00 that counts for the day before keeps hour 1.
    /// Marks saved before hours existed have none, so a day may hold fewer hours than its count.
    private(set) var markHours: [LogicalDay: [Int]] = [:]
    /// Days skipped with Salta oggi, for example when ill: neutral for every Serie.
    var skipped: Set<LogicalDay> = []
    /// Times of day to be reminded, only on expected days and only while not done: the Orari
    /// personalizzati. Empty while it reminds automatically.
    var reminders: [ReminderTime] = []
    /// Orari automatici: one reminder a day at the hour it is usually done, from `markHours`.
    private(set) var remindsAutomatically = false
    /// How its notifications come: time sensitive, the sound, a word when Salute marks it.
    private(set) var notificationStyle = NotificationStyle()
    /// The Salute measure that marks it done by itself, only for a habit to do.
    private(set) var health: HealthLink?
    /// The length in minutes of the countdown that marks an Abitudine a tempo done, `nil` for a
    /// habit that is not timed. Only for a habit to do, never linked to Salute; done once a day.
    /// Not kept per day like the goal: it never changes whether a past day was done.
    private(set) var timerMinutes: Int?
    /// The Nota del giorno of each logical day that has one, as `DailyNote` saves it: never blank.
    /// A skip leaves it, deleting the habit deletes them all.
    private(set) var notes: [LogicalDay: String] = [:]
    /// When each Nota del giorno was last written or cleared, for Sincronizza con iCloud: the
    /// newer edit wins. A cleared note keeps its date, so clearing it travels too.
    private(set) var noteDates: [LogicalDay: Date] = [:]
    /// When its settings were last changed by adding or editing it, for Sincronizza con iCloud:
    /// the newer edit wins. Marks, skips and notes never change it. `nil` before sync existed.
    var modifiedAt: Date?

    init(id: UUID = UUID(), title: String, symbol: String, timesPerDay: Int = 1, schedule: Schedule = .everyDay, limit: Int? = nil, createdOn: LogicalDay) {
        self.id = id
        self.title = title
        self.symbol = symbol
        self.timesPerDay = timesPerDay
        self.schedule = schedule
        self.limit = limit
        self.createdOn = createdOn
    }

    // Files saved before times per day, schedules, limits, skips, reminders, edits, Salute, mark hours and
    // timers and notes existed: yes/no, every day, to do, nothing skipped, no reminders, never edited,
    // marked by hand, no hours, not timed, no notes.
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        symbol = try container.decode(String.self, forKey: .symbol)
        timesPerDay = try container.decodeIfPresent(Int.self, forKey: .timesPerDay) ?? 1
        schedule = try container.decodeIfPresent(Schedule.self, forKey: .schedule) ?? .everyDay
        limit = try container.decodeIfPresent(Int.self, forKey: .limit)
        createdOn = try container.decode(LogicalDay.self, forKey: .createdOn)
        log = try container.decode([LogicalDay: Int].self, forKey: .log)
        markHours = try container.decodeIfPresent([LogicalDay: [Int]].self, forKey: .markHours) ?? [:]
        skipped = try container.decodeIfPresent(Set<LogicalDay>.self, forKey: .skipped) ?? []
        reminders = try container.decodeIfPresent([ReminderTime].self, forKey: .reminders) ?? []
        // Before Orari automatici, times meant Orari personalizzati and none, no reminders.
        remindsAutomatically = try container.decodeIfPresent(Bool.self, forKey: .remindsAutomatically) ?? false
        notificationStyle = try container.decodeIfPresent(NotificationStyle.self, forKey: .notificationStyle) ?? NotificationStyle()
        earlier = try container.decodeIfPresent([HabitSettings].self, forKey: .earlier) ?? []
        health = try container.decodeIfPresent(HealthLink.self, forKey: .health)
        timerMinutes = try container.decodeIfPresent(Int.self, forKey: .timerMinutes)
        notes = try container.decodeIfPresent([LogicalDay: String].self, forKey: .notes) ?? [:]
        noteDates = try container.decodeIfPresent([LogicalDay: Date].self, forKey: .noteDates) ?? [:]
        modifiedAt = try container.decodeIfPresent(Date.self, forKey: .modifiedAt)
    }

    /// Nessun promemoria, Orari automatici or Orari personalizzati.
    var reminderMode: ReminderMode {
        if remindsAutomatically { return .automatic }
        return reminders.isEmpty ? .off : .custom
    }

    /// The times to remind on an expected day: its own, the one `AutomaticReminder` reads from
    /// the marks up to `today`, or none.
    func reminderTimes(through today: LogicalDay, startHour: Int) -> [ReminderTime] {
        switch reminderMode {
        case .off: []
        case .automatic: [AutomaticReminder.time(from: markHours, through: today, startHour: startHour)]
        case .custom: reminders
        }
    }

    /// The countdown of an Abitudine a tempo, `nil` for a habit that is not timed.
    var timerDuration: Duration? {
        timerMinutes.map { .seconds($0 * 60) }
    }

    /// The schedule that applied on `day`.
    func schedule(on day: LogicalDay) -> Schedule {
        earlier.first { day < $0.until }?.schedule ?? schedule
    }

    /// The times per day that applied on `day`.
    func timesPerDay(on day: LogicalDay) -> Int {
        earlier.first { day < $0.until }?.timesPerDay ?? timesPerDay
    }

    /// The Limite that applied on `day`, `nil` for a habit to do.
    func limit(on day: LogicalDay) -> Int? {
        guard limit != nil else { return nil }
        return earlier.first { day < $0.until }.flatMap(\.limit) ?? limit
    }

    /// Times it was done on `day`, or for an Abitudine da evitare, times the user gave in.
    func count(on day: LogicalDay) -> Int {
        log[day, default: 0]
    }

    /// Done on `day` only when every time that day asked for is done; an Abitudine da evitare,
    /// while within its Limite.
    func isDone(on day: LogicalDay) -> Bool {
        if let limit = limit(on: day) { return count(on: day) <= limit }
        return count(on: day) >= timesPerDay(on: day)
    }

    /// An Abitudine da evitare gone over its Limite on `day`: missed for good, today too.
    func isOverLimit(on day: LogicalDay) -> Bool {
        limit(on: day).map { count(on: day) > $0 } ?? false
    }

    /// Applies the form's fields from `today` on, trimmed and kept in range. Past days keep the
    /// goal and schedule they had: changing them never rewrites the past.
    /// - Returns: `false`, changing nothing, when the title is blank or no weekday is chosen.
    /// An Abitudine da evitare keeps its kind: it takes `limit`, has no reminders, no schedule
    /// counted in weeks or months, is never an Attività di un giorno and has no link to Salute.
    /// A habit linked to Salute is done once a day, when the goal is reached.
    /// An Abitudine a tempo is done once a day, when its countdown of `timerMinutes` ends; it is
    /// never linked to Salute, and a link wins over the timer.
    /// Reminding automatically drops the `reminders` times; only a habit linked to Salute keeps
    /// the word when it marks itself, and an Abitudine da evitare keeps no notification setting.
    mutating func update(title: String, symbol: String, timesPerDay: Int, schedule: Schedule, limit: Int? = nil, reminders: [ReminderTime] = [], remindsAutomatically: Bool = false, notificationStyle: NotificationStyle = NotificationStyle(), health: HealthLink? = nil, timerMinutes: Int? = nil, from today: LogicalDay) -> Bool {
        let title = String(title.trimmingCharacters(in: .whitespacesAndNewlines).prefix(Self.maxTitleLength))
        guard title.isEmpty == false, schedule != .weekdays([]) else { return false }
        self.title = title
        self.symbol = symbol
        let newLimit = self.limit.map { Self.clamp(limit ?? $0, to: Self.limitRange) }
        let newHealth = newLimit == nil ? health.map { HealthLink(measure: $0.measure, goal: $0.goal) } : nil
        self.remindsAutomatically = newLimit == nil && remindsAutomatically
        self.reminders = newLimit == nil && remindsAutomatically == false ? Array(Set(reminders)).sorted() : []
        var style = newLimit == nil ? notificationStyle : NotificationStyle()
        style.announcesHealthMark = style.announcesHealthMark && newHealth != nil
        self.notificationStyle = style
        let newTimer = newLimit == nil && newHealth == nil ? timerMinutes.map { Self.clamp($0, to: Self.timerMinutesRange) } : nil
        let newSchedule: Schedule
        let newTimes: Int
        if newLimit != nil, schedule.isCounted || schedule.isOneDay {
            // A limit is per day, and kept every day: an Abitudine da evitare is never counted in
            // weeks or months, nor an Attività di un giorno.
            newSchedule = .everyDay
            newTimes = 1
        } else if case .timesPerWeek(let times) = schedule {
            newSchedule = .timesPerWeek(Self.clamp(times, to: Schedule.timesPerWeekRange))
            // A weekly habit counts days, so it is done once a day.
            newTimes = 1
        } else if case .timesPerMonth(let times) = schedule {
            newSchedule = .timesPerMonth(Self.clamp(times, to: Schedule.timesPerMonthRange))
            // So does a monthly one.
            newTimes = 1
        } else {
            newSchedule = schedule
            // Salute marks the whole day at once, and so does the end of a countdown.
            newTimes = newHealth == nil && newTimer == nil ? Self.clamp(timesPerDay, to: Self.timesPerDayRange) : 1
        }
        // Keep the old rules for the days before today, once per day of edits.
        if (newSchedule, newTimes, newLimit) != (self.schedule, self.timesPerDay, self.limit), today > createdOn, earlier.last?.until != today {
            earlier.append(HabitSettings(until: today, timesPerDay: self.timesPerDay, schedule: self.schedule, limit: self.limit))
        }
        self.schedule = newSchedule
        self.timesPerDay = newTimes
        self.limit = newLimit
        self.health = newHealth
        self.timerMinutes = newTimer
        return true
    }

    /// The Nota del giorno of `day`, `nil` when it has none.
    func note(on day: LogicalDay) -> String? {
        notes[day]
    }

    /// Writes the Nota del giorno of `day`, trimmed and cut to `DailyNote.maxLength`; a blank
    /// text removes it.
    /// - Parameter date: When it was written, for Sincronizza con iCloud.
    mutating func setNote(_ text: String, on day: LogicalDay, at date: Date? = nil) {
        notes[day] = DailyNote.normalized(text)
        if let date {
            noteDates[day] = date
        }
    }

    func isSkipped(on day: LogicalDay) -> Bool {
        skipped.contains(day)
    }

    /// Adds one time on `day`, and takes back a skip; a habit to do already done stays as it is,
    /// an Abitudine da evitare counts every time the user gave in, over the Limite too.
    /// - Parameter hour: The hour on the clock when it was marked, 0 to 23.
    mutating func mark(on day: LogicalDay, hour: Int) {
        guard limit(on: day) != nil || isDone(on: day) == false else { return }
        skipped.remove(day)
        log[day, default: 0] += 1
        markHours[day, default: []].append(hour)
    }

    /// Marks every time left on `day` at once, as Salute does when the goal is reached.
    /// - Parameter hour: The hour on the clock when it was marked, 0 to 23.
    mutating func fill(on day: LogicalDay, hour: Int) {
        let left = timesPerDay(on: day) - count(on: day)
        guard left > 0 else { return }
        log[day] = timesPerDay(on: day)
        markHours[day, default: []].append(contentsOf: repeatElement(hour, count: left))
    }

    /// Takes back the last time marked on `day`, with its hour.
    mutating func undoLast(on day: LogicalDay) {
        guard count(on: day) > 0 else { return }
        let left = count(on: day) - 1
        log[day] = left > 0 ? left : nil
        // The last mark is the newest: if any mark that day has an hour, it does.
        _ = markHours[day]?.popLast()
        if markHours[day]?.isEmpty == true {
            markHours[day] = nil
        }
    }

    /// Skips `day`, clearing its marks and their hours, or takes the skip back.
    mutating func toggleSkip(on day: LogicalDay) {
        if skipped.remove(day) == nil {
            skipped.insert(day)
            log[day] = nil
            markHours[day] = nil
        }
    }

    // MARK: - Sharing

    /// The habit as an Abitudine condivisa shows it to other people: title, symbol, the goal and
    /// schedule history, the log with its hours, the skips and the first day. Never the reminders,
    /// the notification settings, the notes, the countdown or which Salute measure marks it.
    var sharedCopy: Habit {
        var copy = self
        copy.reminders = []
        copy.remindsAutomatically = false
        copy.notificationStyle = NotificationStyle()
        copy.health = nil
        copy.timerMinutes = nil
        copy.notes = [:]
        copy.noteDates = [:]
        copy.modifiedAt = nil
        return copy
    }

    // MARK: - Merge

    /// The same habit with its settings only: no marks, skips or notes. Two copies whose
    /// settings match are equal this way.
    var settingsOnly: Habit {
        var copy = self
        copy.log = [:]
        copy.markHours = [:]
        copy.skipped = []
        copy.notes = [:]
        copy.noteDates = [:]
        return copy
    }

    /// Sets what happened on `day` as a merge decided it: the count, its hours and the skip.
    mutating func setDay(count: Int, hours: [Int], isSkipped: Bool, on day: LogicalDay) {
        log[day] = count > 0 ? count : nil
        markHours[day] = hours.isEmpty ? nil : hours
        if isSkipped {
            skipped.insert(day)
        } else {
            skipped.remove(day)
        }
    }

    /// Sets the Nota del giorno of `day` and its date as a merge decided them, already saved
    /// once so not normalized again.
    mutating func restoreNote(_ text: String?, editedAt date: Date?, on day: LogicalDay) {
        notes[day] = text
        noteDates[day] = date
    }

    static func clamp<Value: Comparable>(_ value: Value, to range: ClosedRange<Value>) -> Value {
        min(max(value, range.lowerBound), range.upperBound)
    }
}
