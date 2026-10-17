import Foundation
import Testing
@testable import SbuMeds

struct TodayProgressTests {
    private let person = UUID()
    private let id = UUID()

    /// Two doses, at 8 and 20, with the given marks.
    private func progress(_ marks: [Int: DoseMark], person: UUID? = nil, day: Day = Fixtures.today) -> TodayProgress {
        let records = marks.map { hour, mark in
            DoseRecordSnapshot(key: DoseKey(medicineID: id, day: day, minutes: hour * 60), mark: mark, markedAt: Fixtures.now)
        }
        let medicine = Fixtures.medicine(id: id, times: [DoseTime(hour: 8), DoseTime(hour: 20)], start: Fixtures.day(-7), records: records)
        let plan = DayPlan([medicine], day: day, now: Fixtures.now, calendar: Fixtures.calendar)
        return TodayProgress(personID: person ?? self.person, plan: plan)
    }

    @Test func takingTheLastDoseCloses() {
        #expect(progress([8: .taken, 20: .taken]).closes(after: progress([8: .taken])))
    }

    @Test func aDoseLeftClosesNothing() {
        #expect(!progress([8: .taken]).closes(after: progress([:])))
    }

    @Test func skippingTheLastDoseClosesNothing() {
        #expect(!progress([8: .taken, 20: .skipped]).closes(after: progress([8: .taken])))
    }

    @Test func anotherPersonOrDayClosesNothing() {
        let done = progress([8: .taken, 20: .taken])
        #expect(!done.closes(after: progress([8: .taken], person: UUID())))
        #expect(!progress([8: .taken, 20: .taken], day: Fixtures.day(-1)).closes(after: progress([8: .taken])))
    }
}
