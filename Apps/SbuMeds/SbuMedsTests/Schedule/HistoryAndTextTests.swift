import Foundation
import Testing
@testable import SbuMeds

struct HistoryAndTextTests {
    private let calendar = Fixtures.calendar

    /// A closed day shows what the history holds, even after the times changed: never a new
    /// "missed" dose at a time that did not exist then.
    @Test func aClosedDayIsTheHistoryAlone() {
        let id = UUID()
        let yesterday = Fixtures.day(-1)
        let taken = DoseRecordSnapshot(key: DoseKey(medicineID: id, day: yesterday, minutes: 8 * 60), mark: .taken)
        let medicine = MedicineSnapshot(
            id: id, name: "Ramipril", schedule: Schedule(times: [DoseTime(hour: 9), DoseTime(hour: 21)], start: Fixtures.day(-10)),
            records: [taken], closedThrough: yesterday
        )
        let plan = DayPlan([medicine], day: yesterday, now: Fixtures.now, calendar: calendar)
        #expect(plan.items.map(\.key.minutes) == [8 * 60])
        #expect(plan.items.map(\.state) == [.taken(at: Fixtures.day(-1).date(atMinutes: 8 * 60, in: calendar))])
    }

    @Test func adherenceCountsWhatIsDueAndNotWhatIsComing() {
        let id = UUID()
        let records = [
            DoseRecordSnapshot(key: DoseKey(medicineID: id, day: Fixtures.day(-2), minutes: 8 * 60), mark: .taken),
            DoseRecordSnapshot(key: DoseKey(medicineID: id, day: Fixtures.day(-1), minutes: 8 * 60), mark: .skipped),
            DoseRecordSnapshot(key: DoseKey(medicineID: id, day: Fixtures.today, minutes: 8 * 60), mark: .taken),
            DoseRecordSnapshot(key: DoseKey(medicineID: id, day: Fixtures.today, minutes: 9 * 60), mark: .taken, isExtra: true),
        ]
        let medicine = Fixtures.medicine(id: id, times: [DoseTime(hour: 8), DoseTime(hour: 20)], start: Fixtures.day(-2), records: records)
        let adherence = Adherence([medicine], from: Fixtures.day(-2), through: Fixtures.today, now: Fixtures.now, calendar: calendar)
        // Day -2: taken + missed 20:00; day -1: skipped + missed; today: taken, 20:00 still coming.
        #expect(adherence.taken == 2)
        #expect(adherence.skipped == 1)
        #expect(adherence.missed == 2)
        #expect(adherence.rate == 0.4)
        #expect(Adherence(taken: 0, skipped: 0, missed: 0).rate == nil)
    }

    @Test func historyIsLatestFirstWithoutMovedDoses() {
        let id = UUID()
        let records = [
            DoseRecordSnapshot(key: DoseKey(medicineID: id, day: Fixtures.day(-40), minutes: 8 * 60), mark: .taken),
            DoseRecordSnapshot(key: DoseKey(medicineID: id, day: Fixtures.today, minutes: 8 * 60), mark: .moved),
            DoseRecordSnapshot(key: DoseKey(medicineID: id, day: Fixtures.day(-1), minutes: 20 * 60), mark: .missed),
            DoseRecordSnapshot(key: DoseKey(medicineID: id, day: Fixtures.day(-1), minutes: 8 * 60), mark: .taken),
        ]
        let medicine = Fixtures.medicine(id: id, records: records)
        #expect(MedicineHistory.entries(of: medicine).map(\.key.minutes) == [20 * 60, 8 * 60, 8 * 60])
        #expect(MedicineHistory.months(of: medicine).map(\.month.month) == [10, 9])
    }

    @Test func weekStartsOnMondayInItaly() {
        let week = Fixtures.today.week(in: calendar)
        #expect(week.first == Day(year: 2026, month: 10, day: 12))
        #expect(week.last == Day(year: 2026, month: 10, day: 18))
    }

    @Test func schedulesReadInWords() {
        var schedule = Schedule(times: [DoseTime(hour: 20), DoseTime(hour: 8)], start: Fixtures.today)
        #expect(ScheduleText.summary(of: schedule, calendar: calendar).hasSuffix("08:00 e 20:00"))
        schedule.frequency = .asNeeded
        #expect(ScheduleText.times(of: schedule, calendar: calendar).isEmpty)
        schedule.frequency = .weekdays
        schedule.weekdays = [1, 2, 4]
        // Monday first, Sunday last in Italy.
        let days = ScheduleText.days(of: schedule, calendar: calendar)
        #expect(days.hasPrefix(calendar.shortWeekdaySymbols[1]))
        #expect(days.hasSuffix(calendar.shortWeekdaySymbols[0]))
    }
}
