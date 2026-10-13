import Foundation

/// What the habit form edits, before it is saved: every setting of every kind, so switching
/// kind or schedule back and forth keeps what was typed. Saving keeps only what the kind uses.
nonisolated struct HabitDraft: Equatable, Sendable {
    /// The durations, in minutes, the Durata screen offers.
    private static let timerChoices = [1, 2, 3, 5, 10, 15, 20, 25, 30, 45, 60, 90, 120, 180]

    var kind: HabitKind {
        didSet { dropUnavailableSchedule() }
    }
    /// As typed: empty means automatic.
    var title: String
    var symbol: String
    var timesPerDay: Int
    var limit: Int
    var scheduleKind: ScheduleKind
    var weekdays: Set<Int>
    var timesPerWeek: Int
    var timesPerMonth: Int
    /// The day of an Attività di un giorno, at noon.
    var oneDay: Date
    var linksHealth: Bool {
        didSet { followHealthSymbol(replacing: nil) }
    }
    var healthMeasure: HealthMeasure {
        didSet { followHealthSymbol(replacing: oldValue.symbol) }
    }
    var healthGoal: Double
    var timerMinutes: Int
    /// Orari personalizzati keeps its times in the form while another mode is chosen.
    var reminderMode: ReminderMode
    var notificationStyle: NotificationStyle

    /// A new habit's draft, or `habit`'s settings.
    init(habit: Habit?, today: LogicalDay, calendar: Calendar = .current) {
        kind = if habit?.limit != nil {
            .toAvoid
        } else if habit?.timerMinutes != nil {
            .timed
        } else {
            .toDo
        }
        title = habit?.title ?? ""
        symbol = habit?.symbol ?? HabitSymbol.all[0].id
        timesPerDay = habit?.timesPerDay ?? 1
        limit = habit?.limit ?? 0
        scheduleKind = .everyDay
        weekdays = Set(1...7)
        timesPerWeek = 3
        timesPerMonth = 10
        oneDay = today.noon(in: calendar)
        let measure = habit?.health?.measure ?? .steps
        linksHealth = habit?.health != nil
        healthMeasure = measure
        healthGoal = habit?.health?.goal ?? measure.defaultGoal
        timerMinutes = habit?.timerMinutes ?? 10
        reminderMode = habit?.reminderMode ?? .off
        notificationStyle = habit?.notificationStyle ?? NotificationStyle()
        setSchedule(habit?.schedule ?? .everyDay, calendar: calendar)
    }

    /// Sets the Giorni screen to `schedule`, keeping the values of the other kinds of schedule.
    mutating func setSchedule(_ schedule: Schedule, calendar: Calendar = .current) {
        scheduleKind = ScheduleKind(schedule)
        switch schedule {
        case .everyDay: break
        case .weekdays(let days): weekdays = days
        case .timesPerWeek(let times): timesPerWeek = times
        case .timesPerMonth(let times): timesPerMonth = times
        case .oneDay(let day): oneDay = day.noon(in: calendar)
        }
    }

    func schedule(in calendar: Calendar = .current) -> Schedule {
        switch scheduleKind {
        case .everyDay: .everyDay
        case .weekdays: .weekdays(weekdays)
        case .timesPerWeek: .timesPerWeek(timesPerWeek)
        case .timesPerMonth: .timesPerMonth(timesPerMonth)
        case .oneDay: .oneDay(LogicalDay(oneDay, calendar: calendar))
        }
    }

    /// The Limite to save, only for an Abitudine da evitare.
    var savedLimit: Int? {
        kind == .toAvoid ? limit : nil
    }

    /// The link to save, only for a habit to do: Salute or the countdown marks it done, never both.
    var healthLink: HealthLink? {
        kind == .toDo && linksHealth ? HealthLink(measure: healthMeasure, goal: healthGoal) : nil
    }

    /// The countdown to save, only for an Abitudine a tempo.
    var savedTimerMinutes: Int? {
        kind == .timed ? timerMinutes : nil
    }

    /// What the goal row sets. A habit counted in weeks or months is done once a day, its count
    /// is on the Giorni screen; so is one linked to Salute, whose goal is the measure's.
    var goal: HabitGoal? {
        switch kind {
        case .toAvoid: .limit
        case .timed: .duration
        case .toDo where linksHealth: .health
        case .toDo where scheduleKind.isCounted: nil
        case .toDo: .timesPerDay
        }
    }

    /// Only a habit to do links to Salute.
    var canLinkHealth: Bool {
        kind == .toDo
    }

    /// An Abitudine da evitare has no reminders.
    var hasReminders: Bool {
        kind != .toAvoid
    }

    /// Only a habit Salute marks can say so.
    var canAnnounceHealthMark: Bool {
        healthLink != nil
    }

    /// The style to save: the word when Salute marks it only while it is linked.
    var savedNotificationStyle: NotificationStyle {
        var style = notificationStyle
        style.announcesHealthMark = style.announcesHealthMark && canAnnounceHealthMark
        return style
    }

    /// A week with no days would never be expected.
    var canSave: Bool {
        scheduleKind != .weekdays || weekdays.isEmpty == false
    }

    /// The SF Symbol before the title preview: the heart for Salute, the ⊘ for Da evitare.
    var titleMark: String? {
        switch kind {
        case .toAvoid: "nosign"
        case .toDo where linksHealth: "heart.fill"
        case .toDo, .timed: nil
        }
    }

    /// The preview ring's segments, as the grid will draw it today.
    var ringSegments: Int {
        switch goal {
        case .limit: max(limit, 1)
        case .timesPerDay: timesPerDay
        case .duration, .health, nil: 1
        }
    }

    /// An Abitudine da evitare starts the day with its whole margin; a habit to do, empty.
    var ringFilled: Double {
        kind == .toAvoid ? Double(ringSegments) : 0
    }

    /// The Durata screen's choices, with the habit's own if a file brought another.
    var durationChoices: [Int] {
        Set(Self.timerChoices + [timerMinutes]).sorted()
    }

    /// The title typed, or the automatic one when it is blank: the one shown and saved.
    func resolvedTitle(locale: Locale = .current) -> String {
        let typed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        return typed.isEmpty ? automaticTitle(locale: locale) : typed
    }

    /// The title a blank Titolo stands for: the Salute goal in words for a linked habit
    /// ("Camminare 8000 passi"), otherwise the symbol's name; never longer than a title can be.
    func automaticTitle(locale: Locale = .current) -> String {
        var title: LocalizedStringResource
        if let link = healthLink {
            let amount = link.measure.formatted(link.goal, locale: locale)
            title = switch link.measure {
            case .steps: "Camminare \(amount)"
            case .water: "Bere \(amount)"
            case .mindfulMinutes: "Meditare \(amount)"
            case .walkingRunningDistance: "Camminare o correre \(amount)"
            case .activeEnergy: "Bruciare \(amount)"
            case .cyclingDistance: "Pedalare \(amount)"
            case .swimmingDistance: "Nuotare \(amount)"
            case .flightsClimbed: "Salire \(amount)"
            case .exerciseMinutes: "Fare esercizio \(amount)"
            case .standMinutes: "Stare in piedi \(amount)"
            case .timeInDaylight: "Stare alla luce \(amount)"
            case .sleep: "Dormire \(amount)"
            case .activityRings: "Chiudere \(amount)"
            }
        } else {
            title = HabitSymbol.named(symbol)?.name ?? "Abitudine"
        }
        title.locale = locale
        return String(String(localized: title).prefix(Habit.maxTitleLength))
    }

    /// Linking to a measure gives the habit the measure's symbol while the symbol is still the
    /// default one, or the one the previous measure gave it: never a symbol you picked.
    private mutating func followHealthSymbol(replacing previous: String?) {
        guard linksHealth, symbol == HabitSymbol.all[0].id || symbol == previous else { return }
        symbol = healthMeasure.symbol
    }

    /// An Abitudine da evitare keeps only the schedules it can have.
    private mutating func dropUnavailableSchedule() {
        if ScheduleKind.choices(for: kind).contains(scheduleKind) == false {
            scheduleKind = .everyDay
        }
    }
}
