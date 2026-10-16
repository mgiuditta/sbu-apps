import Foundation
import PDFKit
import Testing
@testable import SbuMeds

struct ReportTests {
    private let calendar = Fixtures.calendar

    private func history(_ id: UUID) -> [DoseRecordSnapshot] {
        [
            DoseRecordSnapshot(key: DoseKey(medicineID: id, day: Fixtures.day(-2), minutes: 8 * 60), mark: .taken, markedAt: Fixtures.date(2026, 10, 14, 8, 5)),
            DoseRecordSnapshot(key: DoseKey(medicineID: id, day: Fixtures.day(-1), minutes: 8 * 60), mark: .skipped),
            DoseRecordSnapshot(key: DoseKey(medicineID: id, day: Fixtures.today, minutes: 8 * 60), mark: .taken, markedAt: Fixtures.date(2026, 10, 16, 8, 1)),
        ]
    }

    @Test func dayByDayWithTimesAndNothingStillToCome() {
        let id = UUID()
        let medicine = Fixtures.medicine("Ramipril", id: id, times: [DoseTime(hour: 8), DoseTime(hour: 20)], start: Fixtures.day(-2), records: history(id))
        let report = Report(personName: "Nonna", medicines: [medicine], from: Fixtures.day(-2), through: Fixtures.today, now: Fixtures.now, calendar: calendar)
        #expect(report.days.map(\.day) == [Fixtures.day(-2), Fixtures.day(-1), Fixtures.today])
        // Today's 20:00 is still to come: not in the report yet.
        #expect(report.days.last?.entries.count == 1)
        #expect(report.days.first?.entries.map(\.state) == [.taken(at: Fixtures.date(2026, 10, 14, 8, 5)), .missed])
        #expect(report.adherence.taken == 2)
        #expect(report.adherence.counted == 5)
        #expect(report.medicines.first?.adherence == report.adherence)
    }

    @Test func periodsEndTodayAndCustomOnesAreOrdered() {
        let today = Fixtures.today
        #expect(ReportPeriod.week.range(today: today, customFirst: today, customLast: today, calendar: calendar).first == Fixtures.day(-6))
        #expect(ReportPeriod.month.range(today: today, customFirst: today, customLast: today, calendar: calendar).first == Fixtures.day(-29))
        let custom = ReportPeriod.custom.range(today: today, customFirst: Fixtures.day(-1), customLast: Fixtures.day(-9), calendar: calendar)
        #expect(custom.first == Fixtures.day(-9) && custom.last == Fixtures.day(-1))
    }

    @Test func fileNamesAreSafe() {
        let report = Report(personName: "Rita/Ma:ria", medicines: [], from: Fixtures.day(-6), through: Fixtures.today, now: Fixtures.now, calendar: calendar)
        #expect(!report.fileName.contains("/") && !report.fileName.contains(":"))
        #expect(report.fileName.hasSuffix("20261010-20261016.pdf"))
    }

    @Test func thePDFHasPagesAndSaysWhatHappened() throws {
        let id = UUID()
        let medicine = Fixtures.medicine("Ramipril", id: id, times: [DoseTime(hour: 8)], start: Fixtures.day(-89), records: history(id))
        let report = Report(personName: "Nonna", medicines: [medicine], from: Fixtures.day(-89), through: Fixtures.today, now: Fixtures.now, calendar: calendar)
        let document = try #require(PDFDocument(data: ReportPDF.data(for: report, now: Fixtures.now, calendar: calendar)))
        // Ninety days, one line each: more than one page.
        #expect(document.pageCount > 1)
        let text = document.string ?? ""
        #expect(text.contains("Nonna"))
        #expect(text.contains("Ramipril"))
    }
}
