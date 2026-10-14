import Foundation
import Testing
@testable import SbuSubscriptions

struct MonthCalendarTests {
    func calendar(firstWeekday: Int) -> Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Europe/Rome")!
        // Locale first: setting it resets the first weekday.
        calendar.locale = Locale(identifier: "it_IT")
        calendar.firstWeekday = firstWeekday
        return calendar
    }

    func day(_ year: Int, _ month: Int, _ day: Int, _ calendar: Calendar) -> Date {
        calendar.date(from: DateComponents(year: year, month: month, day: day))!
    }

    // 1 October 2026 is a Thursday.
    @Test(arguments: [(2, 3), (1, 4)])
    func firstDaySitsUnderItsWeekday(firstWeekday: Int, blanks: Int) {
        let calendar = calendar(firstWeekday: firstWeekday)
        let grid = MonthGrid(containing: day(2026, 10, 14, calendar), calendar: calendar)
        #expect(grid.cells.prefix(while: { $0 == nil }).count == blanks)
        #expect(grid.cells.compactMap { $0 }.count == 31)
        #expect(grid.weekdaySymbols.count == 7)
    }

    @Test func monthsMoveAcrossTheYear() {
        let calendar = calendar(firstWeekday: 2)
        let grid = MonthGrid(containing: day(2026, 12, 31, calendar), calendar: calendar).adding(months: 1, calendar: calendar)
        #expect(grid.start == day(2027, 1, 1, calendar))
        #expect(grid.end == day(2027, 2, 1, calendar))
    }

    @Test func paymentsAndTotalsOfTheMonth() {
        let calendar = calendar(firstWeekday: 2)
        let grid = MonthGrid(containing: day(2026, 10, 1, calendar), calendar: calendar)
        let weekly = Subscription(name: "Giornale", price: 2, currencyCode: "EUR", startDate: day(2026, 10, 1, calendar), cycle: .weekly)
        let dollars = Subscription(name: "Design", price: 10, currencyCode: "USD", startDate: day(2026, 9, 20, calendar))
        let paused = Subscription(name: "Palestra", price: 40, currencyCode: "EUR", startDate: day(2026, 1, 5, calendar))
        paused.status = .paused
        let pesos = Subscription(name: "Altro", price: 900, currencyCode: "ARS", startDate: day(2026, 10, 3, calendar))
        let converter = CurrencyConverter(table: ExchangeRates(day: "2026-10-13", perEuro: ["EUR": 1, "USD": 2]))

        let month = MonthPayments([weekly, dollars, paused, pesos], in: grid, today: day(2026, 10, 14, calendar), mainCurrency: "EUR", converter: converter, calendar: calendar)
        #expect(month.payments(on: day(2026, 10, 1, calendar)).map(\.subscription.name) == ["Giornale"])
        #expect(month.payments(on: day(2026, 10, 20, calendar)).map(\.subscription.name) == ["Design"])
        #expect(month.payments(on: day(2026, 10, 5, calendar)).isEmpty, "Paused pays nothing")
        // 5 Thursdays × 2 € + 10 USD at 2 per euro; the pesos have no rate.
        #expect(month.total == 15)
        // From the 14th: the 15th, 22nd, 29th and the 20th.
        #expect(month.remaining == 11)
        #expect(month.missingRates == 1)
    }
}
