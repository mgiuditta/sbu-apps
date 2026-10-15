import Foundation
import Testing
@testable import SbuInventory

struct LowStockReminderTests {
    private let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Europe/Rome")!
        return calendar
    }()
    private let locale = Locale(identifier: "it_IT")

    private func date(_ day: Int, _ hour: Int, _ minute: Int) -> Date {
        calendar.date(from: DateComponents(year: 2026, month: 10, day: day, hour: hour, minute: minute))!
    }

    @Test func nothingLowPlansNothing() {
        #expect(LowStockReminderPlan.plan(lowItems: [], minutesAfterMidnight: 1080, now: date(15, 9, 0), calendar: calendar, locale: locale) == nil)
    }

    @Test func remindsTodayWhenTheTimeIsStillAhead() throws {
        let plan = try #require(LowStockReminderPlan.plan(lowItems: ["Pile AA"], minutesAfterMidnight: 18 * 60, now: date(15, 9, 0), calendar: calendar, locale: locale))
        #expect(plan.date == date(15, 18, 0))
        #expect(plan.body == "Pile AA")
    }

    @Test func remindsTomorrowOnceTheTimeHasPassed() throws {
        let plan = try #require(LowStockReminderPlan.plan(lowItems: ["Pile AA"], minutesAfterMidnight: 18 * 60, now: date(15, 18, 0), calendar: calendar, locale: locale))
        #expect(plan.date == date(16, 18, 0))
    }

    @Test func namesUpToThreeItemsInOrder() throws {
        let plan = try #require(LowStockReminderPlan.plan(lowItems: ["Sale", "Caffè", "Pile AA"], minutesAfterMidnight: 600, now: date(15, 9, 0), calendar: calendar, locale: locale))
        #expect(plan.body == "Caffè, Pile AA e Sale")
    }

    @Test func moreThanThreeNamesTwoAndCountsTheRest() throws {
        let plan = try #require(LowStockReminderPlan.plan(lowItems: ["D", "C", "B", "A", "E"], minutesAfterMidnight: 600, now: date(15, 9, 0), calendar: calendar, locale: locale))
        #expect(plan.body.hasPrefix("A, B"))
        #expect(plan.body.contains("3"))
    }

    @Test func reminderIsOffByDefault() {
        let defaults = UserDefaults(suiteName: UUID().uuidString)!
        let reminders = LowStockReminders(center: SilentReminderCenter(), defaults: defaults)
        #expect(!reminders.isOn)
        #expect(reminders.minutesAfterMidnight == 18 * 60)
    }

    @Test func turningOnIsKeptAndDeniedStaysOff() async {
        let defaults = UserDefaults(suiteName: UUID().uuidString)!
        let reminders = LowStockReminders(center: SilentReminderCenter(), defaults: defaults)
        await reminders.setOn(true)
        #expect(reminders.isOn)
        #expect(LowStockReminders(center: SilentReminderCenter(), defaults: defaults).isOn)

        let denied = LowStockReminders(center: DenyingCenter(), defaults: defaults)
        await denied.setOn(true)
        #expect(!denied.isOn)
        #expect(denied.isDenied)
    }
}

private struct DenyingCenter: ReminderCenter {
    func requestAuthorization() async -> Bool { false }
    func isAuthorized() async -> Bool { false }
    func replace(with reminder: PlannedReminder?) async {}
}
