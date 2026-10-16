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

    @Test func thePlanKeepsTheEarliestUnderTheLimit() {
        let medicines = (0..<6).map { Fixtures.medicine("M\($0)", times: [DoseTime(hour: 13 + $0)]) }
        let reminders = plan(medicines, repeatMinutes: 5, days: 7, limit: 10)
        #expect(reminders.count == 10)
        #expect(reminders.map(\.fireDate) == reminders.map(\.fireDate).sorted())
        #expect(reminders.allSatisfy { Day($0.fireDate, calendar: calendar) == Fixtures.today })
    }

    @Test func repeatsArePlannedOnlyForTheNextDay() {
        let medicine = Fixtures.medicine(times: [DoseTime(hour: 20)])
        let reminders = plan([medicine], repeatMinutes: 10, days: 3)
        let repeats = reminders.filter { $0.kind != .doses(repeat: 0) }
        #expect(repeats.allSatisfy { $0.fireDate.timeIntervalSince(Fixtures.now) <= ReminderPlan.repeatWindow })
        #expect(reminders.filter { $0.kind == .doses(repeat: 0) }.count == 3)
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
