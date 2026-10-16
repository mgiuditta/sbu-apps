import Foundation
import Testing
@testable import SbuMeds

struct StockAndMissedTests {
    private let calendar = Fixtures.calendar

    @Test(arguments: [
        (nil as DoseMark?, DoseMark.taken as DoseMark?, -1.0),
        (.taken, nil, 1),
        (.taken, .skipped, 1),
        (.skipped, .taken, -1),
        (.taken, .taken, 0),
        (.missed, .skipped, 0),
        (.moved, .taken, -1),
    ])
    func stockFollowsTheMark(old: DoseMark?, new: DoseMark?, change: Double) {
        #expect(StockLevel.change(from: old, to: new, amount: 1) == change)
    }

    @Test func stockNeverGoesBelowZeroAndUntrackedStaysUntracked() {
        #expect(StockLevel.applying(-3, to: 2) == 0)
        #expect(StockLevel.applying(-1, to: nil) == nil)
    }

    @Test(arguments: [
        (10.0 as Double?, 10.0 as Double?, true),
        (11, 10, false),
        (0, nil, true),
        (1, nil, false),
        (nil, 10, false),
    ])
    func lowAtOrUnderTheThreshold(stock: Double?, threshold: Double?, low: Bool) {
        #expect(StockLevel(stock: stock, threshold: threshold).isLow == low)
    }

    @Test func missedAreTheUnmarkedDosesOfEndedDays() {
        let id = UUID()
        let marked = DoseRecordSnapshot(key: DoseKey(medicineID: id, day: Fixtures.day(-2), minutes: 8 * 60), mark: .taken)
        let moved = DoseRecordSnapshot(key: DoseKey(medicineID: id, day: Fixtures.day(-1), minutes: 8 * 60), mark: .moved, movedTo: Fixtures.now)
        let medicine = Fixtures.medicine(id: id, times: [DoseTime(hour: 8), DoseTime(hour: 20)], start: Fixtures.day(-10), records: [marked, moved])
        let keys = MissedDoses.keys(for: medicine, closedThrough: Fixtures.day(-3), yesterday: Fixtures.day(-1), calendar: calendar)
        #expect(keys == [
            DoseKey(medicineID: id, day: Fixtures.day(-2), minutes: 20 * 60),
            DoseKey(medicineID: id, day: Fixtures.day(-1), minutes: 8 * 60),
            DoseKey(medicineID: id, day: Fixtures.day(-1), minutes: 20 * 60),
        ])
    }

    @Test func nothingMissedWhenAlreadyClosedOrBeforeTheStart() {
        let medicine = Fixtures.medicine(start: Fixtures.day(-1))
        #expect(MissedDoses.keys(for: medicine, closedThrough: Fixtures.day(-1), yesterday: Fixtures.day(-1), calendar: calendar).isEmpty)
        #expect(MissedDoses.keys(for: medicine, closedThrough: Fixtures.day(-30), yesterday: Fixtures.day(-1), calendar: calendar).count == 1)
    }

    @Test func aLongAbsenceIsCapped() {
        let medicine = Fixtures.medicine(start: Day(year: 2020, month: 1, day: 1))
        let keys = MissedDoses.keys(for: medicine, closedThrough: Day(year: 2020, month: 1, day: 1), yesterday: Fixtures.day(-1), calendar: calendar)
        #expect(keys.count == MissedDoses.maxDays)
    }
}
