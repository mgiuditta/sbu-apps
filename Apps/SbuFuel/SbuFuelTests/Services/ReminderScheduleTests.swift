import Foundation
import Testing
@testable import SbuFuel

struct ReminderScheduleTests {
    private let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Europe/Rome")!
        return calendar
    }()

    private func date(_ year: Int, _ month: Int, _ day: Int, hour: Int = 12) -> Date {
        calendar.date(from: DateComponents(year: year, month: month, day: day, hour: hour))!
    }

    /// 1,000 km every 10 days from 1 January: 100 km a day, last reading 46,000 km on 31 January.
    private var estimate: OdometerEstimate? {
        OdometerEstimate(readings: [(date(2026, 1, 1), 43_000), (date(2026, 1, 11), 44_000), (date(2026, 1, 31), 46_000)])
    }

    @Test func paceComesFromTheFirstAndLastReading() throws {
        let estimate = try #require(estimate)
        #expect(estimate.lastKm == 46_000)
        #expect(try #require(estimate.kmPerDay) == 100)
        let reach = try #require(estimate.date(reaching: 47_000))
        #expect(calendar.isDate(reach, inSameDayAs: date(2026, 2, 10)))
    }

    @Test func lessThanAWeekGivesNoPace() throws {
        let short = try #require(OdometerEstimate(readings: [(date(2026, 1, 1), 43_000), (date(2026, 1, 3), 43_900)]))
        #expect(short.kmPerDay == nil)
        #expect(short.date(reaching: 50_000) == nil)
        #expect(OdometerEstimate(readings: []) == nil)
    }

    nonisolated struct Case: CustomTestStringConvertible, Sendable {
        let name: String
        let rule: ReminderRule
        let status: ReminderStatus
        let remainingKm: Double?
        var testDescription: String { name }
    }

    nonisolated static func cases() -> [Case] {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Europe/Rome")!
        func date(_ year: Int, _ month: Int, _ day: Int) -> Date {
            calendar.date(from: DateComponents(year: year, month: month, day: day, hour: 12))!
        }
        return [
            Case(name: "lontano a chilometri", rule: ReminderRule(everyKm: 15_000, lastDoneDate: date(2026, 1, 1), lastDoneOdometerKm: 45_000),
                 status: .later, remainingKm: 14_000),
            Case(name: "vicino a chilometri", rule: ReminderRule(everyKm: 1_500, lastDoneDate: date(2026, 1, 1), lastDoneOdometerKm: 45_000),
                 status: .soon, remainingKm: 500),
            Case(name: "superato a chilometri", rule: ReminderRule(everyKm: 1_000, lastDoneDate: date(2026, 1, 1), lastDoneOdometerKm: 45_000),
                 status: .overdue, remainingKm: 0),
            Case(name: "scaduto a mesi", rule: ReminderRule(everyMonths: 12, lastDoneDate: date(2025, 1, 31)),
                 status: .overdue, remainingKm: nil),
            Case(name: "tra meno di un mese", rule: ReminderRule(everyMonths: 12, lastDoneDate: date(2025, 2, 20)),
                 status: .soon, remainingKm: nil),
            Case(name: "vale quello che arriva prima", rule: ReminderRule(everyKm: 30_000, everyMonths: 1, lastDoneDate: date(2026, 1, 20), lastDoneOdometerKm: 46_000),
                 status: .soon, remainingKm: 30_000),
        ]
    }

    @Test(arguments: cases())
    func statusAndDistanceLeft(_ example: Case) {
        let due = ReminderSchedule.due(example.rule, estimate: estimate, now: date(2026, 2, 1), calendar: calendar)
        #expect(due.status == example.status)
        #expect(due.remainingKm == example.remainingKm)
    }

    @Test func firstDateIsTheEarlierOfTimeAndEstimatedDistance() throws {
        let rule = ReminderRule(everyKm: 2_000, everyMonths: 12, lastDoneDate: date(2026, 1, 1), lastDoneOdometerKm: 46_000)
        let due = ReminderSchedule.due(rule, estimate: estimate, now: date(2026, 2, 1), calendar: calendar)
        // 2,000 km at 100 km a day from 31 January: 20 February, long before next January.
        #expect(calendar.isDate(try #require(due.firstDate), inSameDayAs: date(2026, 2, 20)))
    }

    @Test func monthsAddFromTheDayItWasDone() throws {
        let rule = ReminderRule(everyMonths: 24, lastDoneDate: date(2025, 3, 31))
        #expect(calendar.isDate(try #require(rule.dueDate(calendar: calendar)), inSameDayAs: date(2027, 3, 31)))
    }

    private func input(_ rule: ReminderRule, now: Date) -> ReminderInput {
        ReminderInput(id: UUID(), vehicleName: "Panda", title: "Cambio olio",
                      due: ReminderSchedule.due(rule, estimate: estimate, now: now, calendar: calendar), dueReading: "60.000 km")
    }

    @Test func planFiresAtNineOnTheDueDay() throws {
        let reminder = input(ReminderRule(everyMonths: 12, lastDoneDate: date(2025, 6, 10)), now: date(2026, 2, 1))
        let plan = ReminderPlan.plan([reminder], now: date(2026, 2, 1), calendar: calendar)
        let notification = try #require(plan.scheduled.first)
        #expect(notification.fireDate == date(2026, 6, 10, hour: 9))
        #expect(notification.title == "Panda: Cambio olio")
        #expect(notification.identifier == reminder.id.uuidString)
        #expect(plan.immediate.isEmpty)
    }

    @Test func aReadingAlreadyPassedIsAnnouncedNow() throws {
        let reminder = input(ReminderRule(everyKm: 500, lastDoneDate: date(2026, 1, 1), lastDoneOdometerKm: 45_000), now: date(2026, 2, 1))
        let plan = ReminderPlan.plan([reminder], now: date(2026, 2, 1), calendar: calendar)
        #expect(plan.scheduled.isEmpty)
        let immediate = try #require(plan.immediate.first)
        #expect(immediate.notification.fireDate == nil)
        #expect(immediate.key == "\(reminder.id.uuidString)-45500")
    }

    @Test func aDateAlreadyPastSendsNothing() {
        let reminder = input(ReminderRule(everyMonths: 1, lastDoneDate: date(2025, 6, 1)), now: date(2026, 2, 1))
        let plan = ReminderPlan.plan([reminder], now: date(2026, 2, 1), calendar: calendar)
        #expect(plan.scheduled.isEmpty)
        #expect(plan.immediate.isEmpty)
    }

    @Test func planKeepsTheNearest64() {
        let reminders = (1...80).map { day in
            input(ReminderRule(everyMonths: 12, lastDoneDate: calendar.date(byAdding: .day, value: day, to: date(2025, 6, 1))!), now: date(2026, 2, 1))
        }
        let plan = ReminderPlan.plan(reminders, now: date(2026, 2, 1), calendar: calendar)
        #expect(plan.scheduled.count == 64)
        #expect(plan.scheduled.first?.fireDate == date(2026, 6, 2, hour: 9))
    }

    @Test func notificationsAreSentOnlyWhenAllowedAndImmediateOnesOnce() async throws {
        let defaults = try #require(UserDefaults(suiteName: "notifications-\(UUID())"))
        let denied = SilentReminderCenter(access: .denied)
        let reminder = input(ReminderRule(everyKm: 500, lastDoneDate: date(2026, 1, 1), lastDoneOdometerKm: 45_000), now: date(2026, 2, 1))
        let blocked = ReminderNotifications(center: denied, defaults: defaults)
        await blocked.reschedule([reminder], now: date(2026, 2, 1), calendar: calendar)
        #expect(denied.sent.isEmpty)
        #expect(blocked.access == .denied)

        let allowed = SilentReminderCenter(access: .allowed)
        let notifications = ReminderNotifications(center: allowed, defaults: defaults)
        await notifications.reschedule([reminder], now: date(2026, 2, 1), calendar: calendar)
        #expect(allowed.sent.count == 1)
        await notifications.reschedule([reminder], now: date(2026, 2, 2), calendar: calendar)
        #expect(allowed.sent.isEmpty)
    }
}
