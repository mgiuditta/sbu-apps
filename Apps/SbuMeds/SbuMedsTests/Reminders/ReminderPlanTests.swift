import Foundation
import Testing
@testable import SbuMeds

struct ReminderPlanTests {
    private let calendar = Fixtures.calendar
    private let it = Locale(identifier: "it_IT")

    private func plan(_ medicines: [MedicineSnapshot], now: Date = Fixtures.now, repeatMinutes: Int = 0, days: Int = 2, limit: Int = 60) -> [PlannedReminder] {
        ReminderPlan.reminders(for: medicines, now: now, calendar: calendar, repeatMinutes: repeatMinutes, days: days, limit: limit, locale: it)
    }

    private func hour(_ date: Date) -> Int { calendar.component(.hour, from: date) }

    @Test func oneNotificationPerPersonAndTimeWithAllItsDoses() {
        let me = UUID(), grandma = UUID()
        let medicines = [
            Fixtures.medicine("Omega 3", times: [DoseTime(hour: 20)], person: me),
            Fixtures.medicine("Ferro", times: [DoseTime(hour: 20)], person: me),
            Fixtures.medicine("Ramipril", times: [DoseTime(hour: 20)], person: grandma, personName: "Nonna"),
        ]
        let today = plan(medicines, days: 1)
        #expect(today.count == 2)
        let mine = today.first { $0.personID == me }
        #expect(mine?.lines.map(\.name) == ["Ferro", "Omega 3"])
        #expect(mine?.doseKeys.count == 2)
        #expect(Set(today.map(\.identifier)).count == 2)
    }

    @Test func pastAndMarkedDosesAreNeverReminded() {
        let id = UUID()
        let taken = DoseRecordSnapshot(key: DoseKey(medicineID: id, day: Fixtures.today, minutes: 18 * 60), mark: .taken)
        let medicine = Fixtures.medicine(id: id, times: [DoseTime(hour: 8), DoseTime(hour: 18), DoseTime(hour: 21)], records: [taken])
        let today = plan([medicine], days: 1)
        #expect(today.map { hour($0.fireDate) } == [21])
    }

    @Test func repeatsComeEveryIntervalThreeTimesAndStopWhenMarked() {
        let id = UUID()
        let medicine = Fixtures.medicine(id: id, times: [DoseTime(hour: 21)])
        let reminders = plan([medicine], repeatMinutes: 10, days: 1)
        #expect(reminders.map { calendar.component(.minute, from: $0.fireDate) } == [0, 10, 20, 30])
        #expect(reminders.map(\.kind) == [.doses(repeat: 0), .doses(repeat: 1), .doses(repeat: 2), .doses(repeat: 3)])
        #expect(reminders.dropFirst().allSatisfy { $0.identifier.hasPrefix(reminders[0].identifier) })

        let taken = DoseRecordSnapshot(key: DoseKey(medicineID: id, day: Fixtures.today, minutes: 21 * 60), mark: .taken)
        let marked = Fixtures.medicine(id: id, times: [DoseTime(hour: 21)], records: [taken])
        #expect(plan([marked], repeatMinutes: 10, days: 1).isEmpty)
    }

    @Test func aLateDoseStillGetsItsRemainingRepeats() {
        let medicine = Fixtures.medicine(times: [DoseTime(hour: 11, minute: 45)])
        let reminders = plan([medicine], repeatMinutes: 10, days: 1)
        // 11:45 and 11:55 are past at 12:00; 12:05 and 12:15 are left.
        #expect(reminders.map { calendar.component(.minute, from: $0.fireDate) } == [5, 15])
    }

    @Test func aMovedDoseIsRemindedAtItsNewTime() {
        let id = UUID()
        let moved = DoseRecordSnapshot(key: DoseKey(medicineID: id, day: Fixtures.today, minutes: 11 * 60), mark: .moved, movedTo: Fixtures.date(2026, 10, 16, 12, 10))
        let medicine = Fixtures.medicine(id: id, times: [DoseTime(hour: 11)], records: [moved])
        let reminders = plan([medicine], days: 1)
        #expect(reminders.map(\.fireDate) == [Fixtures.date(2026, 10, 16, 12, 10)])
        #expect(reminders.first?.doseKeys == [DoseKey(medicineID: id, day: Fixtures.today, minutes: 11 * 60).string])
    }

    @Test func asNeededAndEndedMedicinesNeverRemind() {
        let asNeeded = MedicineSnapshot(name: "Antidolorifico", schedule: Schedule(frequency: .asNeeded, start: Fixtures.today))
        let ended = MedicineSnapshot(name: "Antibiotico", schedule: Schedule(times: [DoseTime(hour: 20)], start: Fixtures.day(-7), end: Fixtures.day(-1)))
        #expect(plan([asNeeded, ended]).isEmpty)
    }

    private func result(_ medicines: [MedicineSnapshot], repeatMinutes: Int = 0, days: Int, limit: Int) -> ReminderPlan.Result {
        ReminderPlan.plan(for: medicines, now: Fixtures.now, calendar: calendar, repeatMinutes: repeatMinutes, days: days, limit: limit, locale: it)
    }

    /// Two people, three doses a day each: the first notifications alone fill the slots, nearest
    /// first, and no slot goes to a repeat.
    @Test func everyDoseGetsItsFirstNotificationBeforeAnyRepeat() {
        let me = Fixtures.medicine("Ramipril", times: [DoseTime(hour: 8), DoseTime(hour: 14), DoseTime(hour: 20)], person: UUID())
        let grandma = Fixtures.medicine("Collirio", times: [DoseTime(hour: 9), DoseTime(hour: 15), DoseTime(hour: 21)], person: UUID(), personName: "Nonna")
        let plan = result([me, grandma], repeatMinutes: 5, days: 30, limit: 10)
        #expect(plan.reminders.count == 10)
        #expect(plan.reminders.allSatisfy { $0.kind == .doses(repeat: 0) })
        #expect(plan.reminders.map(\.fireDate) == plan.reminders.map(\.fireDate).sorted())
        // Today 14, 15, 20, 21; tomorrow 8, 9, 14, 15, 20, 21: ten, through tomorrow at 21:00.
        #expect(plan.coveredUntil == Fixtures.date(2026, 10, 17, 21))
    }

    /// One dose a day for three days in six slots: three firsts, then the three repeats of the nearest.
    @Test func leftoverSlotsGoToTheRepeatsOfTheNearestDoses() {
        let medicine = Fixtures.medicine(times: [DoseTime(hour: 20)])
        let plan = result([medicine], repeatMinutes: 10, days: 3, limit: 6)
        #expect(plan.coveredUntil == nil)
        #expect(plan.reminders.filter { $0.kind == .doses(repeat: 0) }.count == 3)
        let repeats = plan.reminders.filter { $0.kind != .doses(repeat: 0) }
        #expect(repeats.count == 3)
        #expect(repeats.allSatisfy { Day($0.dueDate, calendar: calendar) == Fixtures.today })
    }

    @Test func aLateDoseKeepsItsRepeatsFirst() {
        let late = Fixtures.medicine("Ferro", times: [DoseTime(hour: 11, minute: 55)])
        let later = Fixtures.medicine("Ramipril", times: [DoseTime(hour: 20)])
        let plan = result([late, later], repeatMinutes: 10, days: 1, limit: 3)
        // 20:00's first, then 11:55's repeats still to come (12:05, 12:15).
        #expect(plan.reminders.map { calendar.component(.minute, from: $0.fireDate) } == [5, 15, 0])
    }

    @Test func theRefillKeepsItsSlot() {
        let medicine = Fixtures.medicine(times: [DoseTime(hour: 13)], stock: 3, threshold: 10)
        let plan = result([medicine], days: 30, limit: 5)
        #expect(plan.reminders.count == 5)
        #expect(plan.reminders.filter { $0.identifier.hasPrefix("refill-") }.count == 1)
        #expect(plan.coveredUntil == Fixtures.date(2026, 10, 19, 13))
    }

    @Test(arguments: [
        (nil as Date?, nil as Int?),
        (Fixtures.date(2026, 10, 16, 20), 1),
        (Fixtures.date(2026, 10, 18, 13), 2),
        (Fixtures.date(2026, 10, 19, 11), 2),
        (Fixtures.date(2026, 10, 19, 12), nil),
        (Fixtures.date(2026, 10, 25), nil),
    ])
    func openTheAppOftenEnoughWhenTheSlotsRunOutWithinThreeDays(coveredUntil: Date?, days: Int?) {
        let plan = ReminderPlan.Result(reminders: [], coveredUntil: coveredUntil)
        #expect(ReminderPlan.openEveryDays(plan, now: Fixtures.now) == days)
    }

    @Test func aRealisticFamilyIsCoveredForDays() {
        // Nine dose times a day for three people, repeats every 15 minutes, in iOS's 64 slots.
        let people = (0..<3).map { _ in UUID() }
        let medicines = people.map { Fixtures.medicine(times: [DoseTime(hour: 8), DoseTime(hour: 14), DoseTime(hour: 20)], person: $0) }
        let plan = result(medicines, repeatMinutes: 15, days: 30, limit: 64)
        #expect(plan.reminders.count == 64)
        #expect(ReminderPlan.openEveryDays(plan, now: Fixtures.now) == nil)
    }

    @Test func refillComesWithTheDoseThatReachesTheThreshold() throws {
        // 12 left, threshold 10, two a day at 13 and 21: 11 after 13:00, 10 after 21:00.
        let medicine = Fixtures.medicine(times: [DoseTime(hour: 13), DoseTime(hour: 21)], stock: 12, threshold: 10)
        let refill = try #require(plan([medicine]).first { $0.identifier.hasPrefix("refill-") })
        #expect(hour(refill.fireDate) == 21)
        #expect(refill.kind == .refill(medicineName: "Ramipril", left: 10, form: .tablet))
    }

    @Test func alreadyLowRemindsWithTheNextDose() throws {
        let medicine = Fixtures.medicine(times: [DoseTime(hour: 13)], stock: 3, threshold: 10)
        let refill = try #require(plan([medicine]).first { $0.identifier.hasPrefix("refill-") })
        #expect(hour(refill.fireDate) == 13)
    }

    @Test func noRefillWithoutCountingOrWithPlenty() {
        let plenty = Fixtures.medicine(times: [DoseTime(hour: 13)], stock: 100, threshold: 10)
        let uncounted = Fixtures.medicine(times: [DoseTime(hour: 13)])
        #expect(plan([plenty, uncounted]).allSatisfy { !$0.identifier.hasPrefix("refill-") })
    }

    @Test func wordsNameThePersonOnlyWhenThereAreMore() {
        let medicine = Fixtures.medicine("Ramipril", times: [DoseTime(hour: 20)], personName: "Nonna")
        let reminder = plan([medicine], days: 1)[0]
        #expect(ReminderText.body(for: reminder, showsPerson: false, locale: it).hasPrefix("Ramipril, 1 "))
        #expect(ReminderText.title(for: reminder, showsPerson: true, calendar: calendar).hasPrefix("Nonna · "))
        #expect(ReminderText.title(for: reminder, showsPerson: false, calendar: calendar).hasSuffix("20:00"))
    }
}
