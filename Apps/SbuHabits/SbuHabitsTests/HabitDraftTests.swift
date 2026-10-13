import Foundation
import Testing
@testable import SbuHabits

struct HabitDraftTests {
    private static let italian = Locale(identifier: "it_IT")
    private static let american = Locale(identifier: "en_US")

    private let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Europe/Rome")!
        return calendar
    }()

    private var today: LogicalDay {
        LogicalDay(calendar.date(from: DateComponents(year: 2026, month: 10, day: 14, hour: 9))!, calendar: calendar)
    }

    private func draft(_ change: (inout HabitDraft) -> Void = { _ in }) -> HabitDraft {
        var draft = HabitDraft(habit: nil, today: today, calendar: calendar)
        change(&draft)
        return draft
    }

    // MARK: Automatic title

    @Test(arguments: [
        (HealthMeasure.steps, 8_000.0, "Camminare 8000 passi", "Walk 8,000 steps"),
        (.water, 2_000, "Bere 2000 ml", "Drink 2,000 mL"),
        (.mindfulMinutes, 10, "Meditare 10 min", "Meditate 10 min"),
        (.walkingRunningDistance, 5_000, "Camminare o correre 5 km", "Walk or run 5 km"),
        (.activeEnergy, 400, "Bruciare 400 kcal", "Burn 400 kcal"),
    ])
    func aLinkedHabitIsTitledByItsGoal(measure: HealthMeasure, goal: Double, italian: String, english: String) {
        let linked = draft {
            $0.linksHealth = true
            $0.healthMeasure = measure
            $0.healthGoal = goal
        }

        #expect(linked.automaticTitle(locale: Self.italian) == italian)
        #expect(linked.automaticTitle(locale: Self.american) == english)
    }

    @Test(arguments: [("drop", "Acqua", "Water"), ("book", "Libro", "Book"), ("not.a.symbol", "Abitudine", "Habit")])
    func anotherHabitIsTitledBySymbol(symbol: String, italian: String, english: String) {
        let habit = draft { $0.symbol = symbol }

        #expect(habit.automaticTitle(locale: Self.italian) == italian)
        #expect(habit.automaticTitle(locale: Self.american) == english)
    }

    @Test(arguments: [HabitKind.timed, .toAvoid])
    func onlyAHabitToDoIsTitledBySalute(kind: HabitKind) {
        let habit = draft {
            $0.linksHealth = true
            $0.symbol = "book"
            $0.kind = kind
        }

        #expect(habit.automaticTitle(locale: Self.italian) == "Libro")
    }

    @Test(arguments: HealthMeasure.allCases)
    func anAutomaticTitleFitsATitle(measure: HealthMeasure) {
        let linked = draft {
            $0.linksHealth = true
            $0.healthMeasure = measure
            $0.healthGoal = measure.goalRange.upperBound
        }

        #expect(linked.automaticTitle(locale: Self.italian).count <= Habit.maxTitleLength)
        #expect(linked.automaticTitle(locale: Self.american).count <= Habit.maxTitleLength)
    }

    @Test(arguments: [("", "Acqua"), ("   ", "Acqua"), ("  Leggere ", "Leggere")])
    func aBlankTitleIsTheAutomaticOne(typed: String, resolved: String) {
        #expect(draft { $0.title = typed }.resolvedTitle(locale: Self.italian) == resolved)
    }

    // MARK: Kinds and rows

    @Test(arguments: [
        (true, HabitKind.toDo, false, [HabitKind.toDo, .timed, .toAvoid]),
        (true, .toDo, true, [.toDo, .toAvoid]),
        (false, .toDo, false, [.toDo, .timed]),
        (false, .toDo, true, [.toDo]),
        (false, .timed, false, [.toDo, .timed]),
        (false, .toAvoid, false, [.toAvoid]),
    ])
    func theTipoScreenOffers(isNew: Bool, current: HabitKind, linksHealth: Bool, choices: [HabitKind]) {
        #expect(HabitKind.choices(isNew: isNew, current: current, linksHealth: linksHealth) == choices)
    }

    @Test(arguments: [
        (HabitKind.toDo, ScheduleKind.everyDay, false, HabitGoal?.some(.timesPerDay)),
        (.toDo, .weekdays, false, .timesPerDay),
        (.toDo, .oneDay, false, .timesPerDay),
        (.toDo, .timesPerWeek, false, nil),
        (.toDo, .timesPerMonth, false, nil),
        (.toDo, .timesPerWeek, true, .health),
        (.toDo, .everyDay, true, .health),
        (.timed, .everyDay, false, .duration),
        (.timed, .everyDay, true, .duration),
        (.toAvoid, .everyDay, true, .limit),
    ])
    func theGoalRowFollowsTheKind(kind: HabitKind, schedule: ScheduleKind, linksHealth: Bool, goal: HabitGoal?) {
        let habit = draft {
            $0.kind = kind
            $0.scheduleKind = schedule
            $0.linksHealth = linksHealth
        }

        #expect(habit.goal == goal)
    }

    @Test(arguments: [
        (HabitKind.toDo, true, true, true),
        (.timed, false, true, false),
        (.toAvoid, false, false, false),
    ])
    func rowsForSaluteAndNotifiche(kind: HabitKind, canLinkHealth: Bool, hasReminders: Bool, savesLink: Bool) {
        let habit = draft {
            $0.linksHealth = true
            $0.kind = kind
        }

        #expect(habit.canLinkHealth == canLinkHealth)
        #expect(habit.hasReminders == hasReminders)
        #expect((habit.healthLink != nil) == savesLink)
    }

    @Test(arguments: [ScheduleKind.timesPerWeek, .timesPerMonth, .oneDay])
    func becomingAnAbitudineDaEvitareDropsItsSchedule(schedule: ScheduleKind) {
        let avoided = draft {
            $0.scheduleKind = schedule
            $0.kind = .toAvoid
        }

        #expect(avoided.scheduleKind == .everyDay)
        #expect(ScheduleKind.choices(for: .toAvoid) == [.everyDay, .weekdays])
    }

    @Test func aWeekWithNoDaysCannotBeSaved() {
        #expect(draft { $0.scheduleKind = .weekdays; $0.weekdays = [] }.canSave == false)
        #expect(draft { $0.scheduleKind = .weekdays; $0.weekdays = [2] }.canSave)
        #expect(draft { $0.weekdays = [] }.canSave)
    }

    @Test(arguments: [
        (HabitKind.toDo, false, String?.none),
        (.toDo, true, "heart.fill"),
        (.timed, false, nil),
        (.toAvoid, false, "nosign"),
    ])
    func theTitleIsMarked(kind: HabitKind, linksHealth: Bool, mark: String?) {
        let habit = draft {
            $0.kind = kind
            $0.linksHealth = linksHealth
        }

        #expect(habit.titleMark == mark)
    }

    @Test func theRingShowsTheTimesOrTheLimite() {
        #expect(draft { $0.timesPerDay = 8 }.ringSegments == 8)
        #expect(draft { $0.timesPerDay = 8; $0.scheduleKind = .timesPerWeek }.ringSegments == 1)
        let avoided = draft { $0.kind = .toAvoid; $0.limit = 0 }
        #expect(avoided.ringSegments == 1)
        #expect(avoided.ringFilled == 1)
    }

    // MARK: Saving

    @Test func savingKeepsOnlyWhatTheKindUses() {
        let timed = draft {
            $0.kind = .timed
            $0.timerMinutes = 20
            $0.limit = 3
        }
        #expect(timed.savedTimerMinutes == 20)
        #expect(timed.savedLimit == nil)

        let avoided = draft {
            $0.kind = .toAvoid
            $0.limit = 2
        }
        #expect(avoided.savedLimit == 2)
        #expect(avoided.savedTimerMinutes == nil)
    }

    @Test func aHabitComesBackAsItWasSaved() throws {
        var timed = Habit(title: "Leggere", symbol: "book", schedule: .timesPerWeek(4), createdOn: today)
        _ = timed.update(title: "Leggere", symbol: "book", timesPerDay: 1, schedule: .timesPerWeek(4), timerMinutes: 25, from: today)
        let draft = HabitDraft(habit: timed, today: today, calendar: calendar)

        #expect(draft.kind == .timed)
        #expect(draft.timerMinutes == 25)
        #expect(draft.scheduleKind == .timesPerWeek)
        #expect(draft.timesPerWeek == 4)
        #expect(draft.schedule(in: calendar) == .timesPerWeek(4))
        #expect(draft.durationChoices.contains(25))

        let avoided = HabitDraft(habit: Habit(title: "Caffè", symbol: "cup.and.saucer", limit: 2, createdOn: today), today: today, calendar: calendar)
        #expect(avoided.kind == .toAvoid)
        #expect(avoided.limit == 2)
    }

    @Test func anAttivitaDiUnGiornoKeepsItsDay() {
        let day = today + 3
        let habit = Habit(title: "Dentista", symbol: "cross.case", schedule: .oneDay(day), createdOn: today)

        #expect(HabitDraft(habit: habit, today: today, calendar: calendar).schedule(in: calendar) == .oneDay(day))
    }

    // MARK: Row values

    @Test(arguments: [
        (HabitKind.toDo, 1, 0, "1 volta al giorno"),
        (.toDo, 3, 0, "3 volte al giorno"),
        (.toAvoid, 1, 0, "Mai"),
        (.toAvoid, 1, 2, "2 al giorno"),
        (.timed, 1, 0, "10 min"),
    ])
    func theGoalRowSays(kind: HabitKind, timesPerDay: Int, limit: Int, summary: String) {
        let habit = draft {
            $0.kind = kind
            $0.timesPerDay = timesPerDay
            $0.limit = limit
        }

        #expect(habit.goalSummary(locale: Self.italian) == summary)
    }

    @Test func theGoalRowSaysTheSaluteGoalOrNothing() {
        #expect(draft { $0.linksHealth = true }.goalSummary(locale: Self.italian) == "8000 passi")
        #expect(draft { $0.timesPerDay = 3 }.goalSummary(locale: Self.american) == "3 times a day")
        #expect(draft { $0.scheduleKind = .timesPerMonth }.goalSummary(locale: Self.italian) == nil)
    }

    @Test(arguments: [
        (ScheduleKind.everyDay, Set(1...7), 1, "Ogni giorno"),
        (.weekdays, Set([2, 4, 6]), 1, "lun, mer e ven"),
        (.weekdays, Set<Int>(), 1, "Nessun giorno"),
        (.weekdays, Set(1...7), 1, "Tutti i giorni"),
        (.timesPerWeek, Set(1...7), 1, "1 volta a settimana"),
        (.timesPerWeek, Set(1...7), 3, "3 volte a settimana"),
        (.timesPerMonth, Set(1...7), 10, "10 volte al mese"),
        (.oneDay, Set(1...7), 1, "14 ott"),
    ])
    func theGiorniRowSays(schedule: ScheduleKind, weekdays: Set<Int>, times: Int, summary: String) {
        var monday = calendar
        monday.firstWeekday = 2
        let habit = draft {
            $0.scheduleKind = schedule
            $0.weekdays = weekdays
            $0.timesPerWeek = times
            $0.timesPerMonth = times
        }

        #expect(habit.daysSummary(calendar: monday, locale: Self.italian) == summary)
    }

    @Test func theGiorniRowFollowsTheWeekOfTheLocale() {
        let habit = draft {
            $0.scheduleKind = .weekdays
            $0.weekdays = [1, 2]
        }

        #expect(habit.daysSummary(calendar: calendar, locale: Self.american) == "Sun and Mon")
    }

    @Test func theNotificheRowSays() throws {
        let nine = try #require(calendar.date(from: DateComponents(year: 2026, month: 10, day: 14, hour: 9)))

        #expect(HabitDraft.remindersSummary([], calendar: calendar, locale: Self.italian) == "Nessuna")
        #expect(HabitDraft.remindersSummary([nine], calendar: calendar, locale: Self.italian) == "09:00")
        #expect(HabitDraft.remindersSummary([nine, nine], calendar: calendar, locale: Self.italian) == "2 promemoria")
        #expect(HabitDraft.remindersSummary([nine, nine], calendar: calendar, locale: Self.american) == "2 reminders")
    }

    @Test func theTipoAndSaluteRowsSay() {
        #expect(draft().kindSummary(locale: Self.italian) == "Da fare")
        #expect(draft { $0.kind = .toAvoid }.kindSummary(locale: Self.american) == "To avoid")
        #expect(draft().healthSummary(locale: Self.italian) == "Non collegata")
        #expect(draft { $0.linksHealth = true }.healthSummary(locale: Self.italian) == "Passi")
    }
}
