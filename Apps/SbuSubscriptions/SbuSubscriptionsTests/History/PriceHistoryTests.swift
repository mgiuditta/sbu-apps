import Foundation
import Testing
@testable import SbuSubscriptions

struct PriceHistoryTests {
    let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Europe/Rome")!
        return calendar
    }()

    func day(_ year: Int, _ month: Int, _ day: Int) -> Date {
        calendar.date(from: DateComponents(year: year, month: month, day: day))!
    }

    @Test func withoutChangesThePriceRunsFromTheFirstPayment() {
        let entries = PriceHistory.entries(price: 9.99, start: day(2025, 3, 4), changes: [], through: day(2026, 10, 16), calendar: calendar)
        #expect(entries == [PriceHistory.Entry(date: day(2025, 3, 4), price: 9.99)])
    }

    @Test func changesNewestFirst() {
        let changes: [(date: Date, price: Decimal)] = [(day(2026, 1, 1), 11.99), (day(2026, 6, 1), 12.99)]
        let entries = PriceHistory.entries(price: 12.99, start: day(2025, 3, 4), changes: changes, through: day(2026, 10, 16), calendar: calendar)
        #expect(entries.map(\.price) == [12.99, 11.99])
        #expect(entries.first?.date == day(2026, 6, 1))
    }

    @Test func aChangeStillToComeStaysOut() {
        let changes: [(date: Date, price: Decimal)] = [(day(2026, 11, 1), 14.99)]
        let entries = PriceHistory.entries(price: 12.99, start: day(2025, 3, 4), changes: changes, through: day(2026, 10, 16), calendar: calendar)
        #expect(entries.map(\.price) == [12.99])
    }
}
