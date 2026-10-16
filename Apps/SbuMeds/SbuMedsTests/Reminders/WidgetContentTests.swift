import Foundation
import Testing
@testable import SbuMeds

struct WidgetContentTests {
    private let calendar = Fixtures.calendar

    @Test func countsWhatIsLeftTodayForEveryone() {
        let id = UUID()
        let taken = DoseRecordSnapshot(key: DoseKey(medicineID: id, day: Fixtures.today, minutes: 8 * 60), mark: .taken)
        let medicines = [
            Fixtures.medicine("Ramipril", id: id, times: [DoseTime(hour: 8), DoseTime(hour: 20)], records: [taken], personName: "Io"),
            Fixtures.medicine("Collirio", times: [DoseTime(hour: 11), DoseTime(hour: 21)], personName: "Nonna"),
        ]
        let content = WidgetContent(medicines, at: Fixtures.now, calendar: calendar, limit: 2)
        #expect(content.toTakeCount == 3)
        #expect(content.lateCount == 1)
        #expect(content.items.map(\.name) == ["Collirio", "Ramipril"])
        #expect(content.items.first?.isLate == true)
        #expect(content.items.first?.personName == "Nonna")
        #expect(!content.isEmpty)
    }

    @Test func oneFamilyMemberIsNotNamed() {
        let content = WidgetContent([Fixtures.medicine(times: [DoseTime(hour: 20)])], at: Fixtures.now, calendar: calendar, limit: 5)
        #expect(content.items.first?.personName == "")
        #expect(WidgetContent([], at: Fixtures.now, calendar: calendar, limit: 5).isEmpty)
    }

    @Test func theWidgetChangesAtEachDoseAndAtMidnight() {
        let medicine = Fixtures.medicine(times: [DoseTime(hour: 8), DoseTime(hour: 14), DoseTime(hour: 20)])
        let moments = WidgetContent.moments(for: [medicine], from: Fixtures.now, calendar: calendar, days: 2)
        #expect(moments == [
            Fixtures.now,
            Fixtures.date(2026, 10, 16, 14),
            Fixtures.date(2026, 10, 16, 20),
            Fixtures.date(2026, 10, 17, 0),
            Fixtures.date(2026, 10, 18, 0),
        ])
    }
}
