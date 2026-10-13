import Foundation
import Testing
@testable import SbuHabits

/// The Notifiche screen's settings as the habit keeps them and the plan applies them.
struct ReminderNotificationsTests {
    private let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Europe/Rome")!
        calendar.firstWeekday = 2
        return calendar
    }()

    /// Tuesday 13 October 2026 at `hour`.
    private func date(_ hour: Int, plusDays days: Int = 0) -> Date {
        calendar.date(from: DateComponents(year: 2026, month: 10, day: 13 + days, hour: hour))!
    }

    private var today: LogicalDay { LogicalDay(date(12), calendar: calendar) }

    private func habit(times: [ReminderTime] = [], automatic: Bool = false, style: NotificationStyle = NotificationStyle(), limit: Int? = nil, health: HealthLink? = nil) -> Habit {
        var habit = Habit(title: "Leggere", symbol: "book", limit: limit, createdOn: today - 30)
        _ = habit.update(title: "Leggere", symbol: "book", timesPerDay: 1, schedule: .everyDay, limit: limit, reminders: times, remindsAutomatically: automatic, notificationStyle: style, health: health, from: today - 30)
        return habit
    }

    private func plan(_ habits: [Habit], timer: HabitTimer? = nil) -> [PlannedReminder] {
        ReminderPlan.reminders(for: habits, timer: timer, now: date(12), startHour: 0, calendar: calendar)
    }

    // MARK: Modes

    @Test(arguments: [
        ([ReminderTime](), false, ReminderMode.off),
        ([ReminderTime(hour: 9, minute: 0)], false, .custom),
        ([], true, .automatic),
        ([ReminderTime(hour: 9, minute: 0)], true, .automatic), // automatic drops the times
    ])
    func theModeFollowsWhatWasSaved(times: [ReminderTime], automatic: Bool, mode: ReminderMode) {
        #expect(habit(times: times, automatic: automatic).reminderMode == mode)
    }

    @Test(arguments: [
        (#", "reminders": [{"hour": 9, "minute": 0}]"#, ReminderMode.custom),
        ("", .off),
    ])
    func aFileFromBeforeTheModesKeepsItsReminders(fields: String, mode: ReminderMode) throws {
        let json = #"{"id": "6F9619FF-8B86-D011-B42D-00C04FC964FF", "title": "Leggere", "symbol": "book", "createdOn": 20000, "log": {}"#
            + fields + "}"

        let read = try JSONDecoder().decode(Habit.self, from: Data(json.utf8))

        #expect(read.reminderMode == mode)
        #expect(read.notificationStyle == NotificationStyle())
    }

    @Test func anAbitudineDaEvitareKeepsNoNotificationSetting() {
        let coffee = habit(automatic: true, style: NotificationStyle(isTimeSensitive: true, sound: .punto), limit: 2)

        #expect(coffee.reminderMode == .off)
        #expect(coffee.notificationStyle == NotificationStyle())
    }

    @Test func onlyAHabitSaluteMarksKeepsTheWord() {
        let style = NotificationStyle(announcesHealthMark: true)

        #expect(habit(style: style).notificationStyle.announcesHealthMark == false)
        #expect(habit(style: style, health: HealthLink(measure: .steps, goal: 8_000)).notificationStyle.announcesHealthMark)
    }

    // MARK: Plan

    @Test(arguments: [
        (ReminderMode.off, 0),
        (.custom, ReminderPlan.days * 2),
        (.automatic, ReminderPlan.days),
    ])
    func theModeDecidesWhatIsPlanned(mode: ReminderMode, count: Int) {
        let times = [ReminderTime(hour: 18, minute: 0), ReminderTime(hour: 21, minute: 0)]
        let reading = habit(times: mode == .custom ? times : [], automatic: mode == .automatic)

        #expect(plan([reading]).count == count)
    }

    @Test func automaticRemindersComeAtTheUsualHourAndMoveWithTheMarks() {
        var reading = habit(automatic: true)
        #expect(plan([reading]).first?.date == date(AutomaticReminder.fallback.hour))

        for day in 1...3 {
            reading.mark(on: today - day, hour: 17)
        }

        #expect(plan([reading]).first?.date == date(17))
        #expect(plan([reading]).dropFirst().first?.date == date(17, plusDays: 1))
    }

    @Test(arguments: [false, true], ReminderSound.allCases)
    func eachReminderCarriesTheHabitsStyle(isTimeSensitive: Bool, sound: ReminderSound) {
        let reading = habit(times: [ReminderTime(hour: 20, minute: 0)], style: NotificationStyle(isTimeSensitive: isTimeSensitive, sound: sound))

        #expect(plan([reading]).allSatisfy { $0.isTimeSensitive == isTimeSensitive && $0.sound == sound })
    }

    @Test func theEndOfACountdownIsTimeSensitiveWithItsHabitsSound() throws {
        var reading = habit(style: NotificationStyle(sound: .carta))
        _ = reading.update(title: "Leggere", symbol: "book", timesPerDay: 1, schedule: .everyDay, notificationStyle: NotificationStyle(sound: .carta), timerMinutes: 10, from: today)
        let timer = try #require(HabitTimer(habit: reading, day: today, now: date(12)))

        let end = try #require(plan([reading], timer: timer).first)

        #expect(end.endsTimer)
        #expect(end.isTimeSensitive)
        #expect(end.sound == .carta)
    }

    @Test func theTimerKeepsItsPlaceWithinTheLimit() throws {
        let habits = (0..<5).map { _ in habit(automatic: true) }
        var timed = habit()
        _ = timed.update(title: "Leggere", symbol: "book", timesPerDay: 1, schedule: .everyDay, timerMinutes: 10, from: today)
        let timer = try #require(HabitTimer(habit: timed, day: today, now: date(12)))

        let planned = plan(habits + [timed], timer: timer)

        #expect(planned.count == ReminderPlan.limit)
        #expect(planned.first?.id == ReminderPlan.timerID)
    }

    // MARK: Salute

    @Test(arguments: [false, true])
    func saluteMarkingAHabitSaysSoOnlyWhenAsked(announces: Bool) async {
        let store = HabitsStore(url: .temporaryDirectory.appending(path: "ReminderNotificationsTests-\(UUID().uuidString).json"))
        let health = FakeHealth()
        var announced: [[String]] = []
        let model = HabitsModel(store: store, now: { date(20) }, calendar: calendar, scheduleReminders: { _ in }, health: health, announceHealthMarks: { announced.append($0.map(\.title)) })
        model.add(title: "Camminare", symbol: "figure.walk", notificationStyle: NotificationStyle(announcesHealthMark: announces), health: HealthLink(measure: .steps, goal: 8_000))
        model.observeHealth()

        await health.deliver(FakeHealth.Sample(measure: .steps, date: date(18), amount: 9_000))
        // More steps later the same day: already done, nothing more to say.
        await health.deliver(FakeHealth.Sample(measure: .steps, date: date(19), amount: 1_000))

        #expect(announced == (announces ? [["Camminare"]] : []))
    }
}
