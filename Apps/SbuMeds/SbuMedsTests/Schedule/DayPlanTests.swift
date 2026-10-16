import Foundation
import Testing
@testable import SbuMeds

struct DayPlanTests {
    private let calendar = Fixtures.calendar
    private let today = Fixtures.today

    private func key(_ medicine: MedicineSnapshot, _ hour: Int, _ minute: Int = 0, day: Day = Fixtures.today) -> DoseKey {
        DoseKey(medicineID: medicine.id, day: day, minutes: hour * 60 + minute)
    }

    @Test func dosesAreGroupedByTimeEarliestFirst() {
        let a = Fixtures.medicine("Ramipril", times: [DoseTime(hour: 8), DoseTime(hour: 20)])
        let b = Fixtures.medicine("Atorvastatina", times: [DoseTime(hour: 20)])
        let plan = DayPlan([a, b], day: today, now: Fixtures.date(2026, 10, 16, 6), calendar: calendar)
        #expect(plan.groups.map { calendar.component(.hour, from: $0.dueDate) } == [8, 20])
        #expect(plan.groups[1].items.map(\.medicine.name) == ["Atorvastatina", "Ramipril"])
        #expect(plan.toTakeCount == 3)
    }

    @Test(arguments: [
        (7, DoseState.upcoming),
        (8, DoseState.late),
        (15, DoseState.late),
    ])
    func anUnmarkedDoseTurnsLateAtItsTime(hour: Int, state: DoseState) {
        let medicine = Fixtures.medicine(times: [DoseTime(hour: 8)])
        let plan = DayPlan([medicine], day: today, now: Fixtures.date(2026, 10, 16, hour), calendar: calendar)
        #expect(plan.items.first?.state == state)
    }

    @Test func pastDaysWithoutAMarkAreMissedAndFutureOnesUpcoming() {
        let medicine = Fixtures.medicine(start: Fixtures.day(-5))
        #expect(DayPlan([medicine], day: Fixtures.day(-1), now: Fixtures.now, calendar: calendar).items.first?.state == .missed)
        #expect(DayPlan([medicine], day: Fixtures.day(1), now: Fixtures.now, calendar: calendar).items.first?.state == .upcoming)
    }

    @Test func marksComeFromTheHistory() {
        let id = UUID()
        let takenAt = Fixtures.date(2026, 10, 16, 8, 12)
        let records = [
            DoseRecordSnapshot(key: DoseKey(medicineID: id, day: today, minutes: 8 * 60), mark: .taken, markedAt: takenAt),
            DoseRecordSnapshot(key: DoseKey(medicineID: id, day: today, minutes: 14 * 60), mark: .skipped),
        ]
        let medicine = Fixtures.medicine(id: id, times: [DoseTime(hour: 8), DoseTime(hour: 14), DoseTime(hour: 20)], records: records)
        let plan = DayPlan([medicine], day: today, now: Fixtures.date(2026, 10, 16, 15), calendar: calendar)
        #expect(plan.items.map(\.state) == [.taken(at: takenAt), .skipped, .upcoming])
        #expect(plan.takenCount == 1)
        #expect(plan.toTakeCount == 1)
        #expect(plan.scheduledCount == 3)
    }

    /// Morning and evening doses with different amounts each keep their own, whatever the order of entry.
    @Test func morningAndEveningAmountsAreNeverSwapped() {
        let medicine = Fixtures.medicine(times: [DoseTime(hour: 21, amount: 2), DoseTime(hour: 8, amount: 0.5)])
        let plan = DayPlan([medicine], day: today, now: Fixtures.date(2026, 10, 16, 6), calendar: calendar)
        #expect(plan.items.map { calendar.component(.hour, from: $0.dueDate) } == [8, 21])
        #expect(plan.items.map(\.amount) == [0.5, 2])
    }

    @Test func aMovedDoseGoesToItsNewTimeAndStaysToTake() {
        let id = UUID()
        let movedTo = Fixtures.date(2026, 10, 16, 9, 30)
        let records = [DoseRecordSnapshot(key: DoseKey(medicineID: id, day: today, minutes: 8 * 60), mark: .moved, movedTo: movedTo)]
        let medicine = Fixtures.medicine(id: id, times: [DoseTime(hour: 8)], records: records)
        let before = DayPlan([medicine], day: today, now: Fixtures.date(2026, 10, 16, 9), calendar: calendar)
        #expect(before.groups.map(\.dueDate) == [movedTo])
        #expect(before.items.first?.state == .upcoming)
        #expect(before.items.first?.isMoved == true)
        let after = DayPlan([medicine], day: today, now: Fixtures.date(2026, 10, 16, 10), calendar: calendar)
        #expect(after.items.first?.state == .late)
    }

    @Test func extraDosesShowButDoNotCountInThePlan() {
        let id = UUID()
        let extra = DoseRecordSnapshot(key: DoseKey(medicineID: id, day: today, minutes: 11 * 60), mark: .taken, markedAt: Fixtures.date(2026, 10, 16, 11), isExtra: true)
        let medicine = Fixtures.medicine(id: id, times: [DoseTime(hour: 8)], records: [extra])
        let plan = DayPlan([medicine], day: today, now: Fixtures.now, calendar: calendar)
        #expect(plan.items.count == 2)
        #expect(plan.scheduledCount == 1)
        #expect(plan.toTakeCount == 1)
    }

    /// The schedule changed from 8:00 to 9:00 after the 8:00 dose was taken: the history keeps it.
    @Test func aMarkAtATimeTheScheduleDroppedStaysInTheDay() {
        let id = UUID()
        let old = DoseRecordSnapshot(key: DoseKey(medicineID: id, day: today, minutes: 8 * 60), mark: .taken, markedAt: Fixtures.date(2026, 10, 16, 8))
        let medicine = Fixtures.medicine(id: id, times: [DoseTime(hour: 9)], records: [old])
        let plan = DayPlan([medicine], day: today, now: Fixtures.now, calendar: calendar)
        #expect(plan.items.count == 2)
        #expect(plan.takenCount == 1)
    }

    @Test func nextDoseIsTheFirstStillToTake() throws {
        let id = UUID()
        let taken = DoseRecordSnapshot(key: DoseKey(medicineID: id, day: today, minutes: 8 * 60), mark: .taken)
        let medicine = Fixtures.medicine(id: id, times: [DoseTime(hour: 8), DoseTime(hour: 20)], records: [taken])
        let next = try #require(NextDose.of(medicine, now: Fixtures.now, calendar: calendar))
        #expect(next.key.minutes == 20 * 60)
        let tomorrow = try #require(NextDose.of(medicine, now: Fixtures.date(2026, 10, 16, 23), calendar: calendar))
        // The 20:00 dose is late, still to take: it comes first.
        #expect(tomorrow.key.day == today)
    }

    @Test func nextDoseSkipsACyclePause() throws {
        let medicine = MedicineSnapshot(name: "Pillola", schedule: Schedule(frequency: .cycle, times: [DoseTime(hour: 21)], cycleOn: 21, cycleOff: 7, start: Fixtures.day(-21)))
        let next = try #require(NextDose.of(medicine, now: Fixtures.now, calendar: calendar))
        #expect(next.key.day == Fixtures.day(7))
    }

    @Test func nothingNextAfterTheEndOrAsNeeded() {
        let ended = MedicineSnapshot(name: "Antibiotico", schedule: Schedule(start: Fixtures.day(-7), end: Fixtures.day(-1)))
        #expect(NextDose.of(ended, now: Fixtures.now, calendar: calendar) == nil)
        let asNeeded = MedicineSnapshot(name: "Antidolorifico", schedule: Schedule(frequency: .asNeeded, start: today))
        #expect(NextDose.of(asNeeded, now: Fixtures.now, calendar: calendar) == nil)
    }
}
