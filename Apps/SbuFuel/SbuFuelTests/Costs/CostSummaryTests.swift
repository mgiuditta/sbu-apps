import Foundation
import Testing
@testable import SbuFuel

struct CostSummaryTests {
    private let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Europe/Rome")!
        return calendar
    }()

    private func date(_ year: Int, _ month: Int, _ day: Int) -> Date {
        calendar.date(from: DateComponents(year: year, month: month, day: day, hour: 12))!
    }

    private func fill(_ date: Date, _ km: Double, _ litres: Double, _ price: Decimal) -> FillRecord {
        FillRecord(date: date, odometerKm: km, litres: litres, totalPrice: price)
    }

    @Test func monthAndYearTotalsAddFuelAndServices() {
        let summary = CostSummary(
            fills: [fill(date(2026, 3, 2), 1_000, 40, 70), fill(date(2026, 3, 20), 1_500, 30, 55), fill(date(2026, 1, 5), 500, 30, 50)],
            services: [ServiceCost(date: date(2026, 3, 10), cost: 89), ServiceCost(date: date(2025, 12, 31), cost: 200)],
            calendar: calendar
        )
        #expect(summary.spent(inMonthOf: date(2026, 3, 15)) == 214)
        #expect(summary.spent(inYearOf: date(2026, 6, 1)) == 264)
        #expect(summary.total == 464)
    }

    @Test func costPerKilometreLeavesOutTheFirstFill() throws {
        let summary = CostSummary(fills: [fill(date(2026, 1, 1), 1_000, 40, 80), fill(date(2026, 1, 20), 1_500, 30, 60)], services: [], calendar: calendar)
        #expect(try #require(summary.fuelCostPerKm) == Decimal(string: "0.12"))
    }

    @Test func costPerKilometreNeedsTwoReadings() {
        let summary = CostSummary(fills: [fill(date(2026, 1, 1), 1_000, 40, 80)], services: [], calendar: calendar)
        #expect(summary.fuelCostPerKm == nil)
    }

    @Test func freeFillsCountInConsumptionNotInTheAveragePrice() throws {
        let summary = CostSummary(fills: [fill(date(2026, 1, 1), 1_000, 40, 80), fill(date(2026, 1, 20), 1_500, 30, 0)], services: [], calendar: calendar)
        #expect(try #require(summary.averagePricePerLitre) == 2)
    }

    @Test func noPaidFillNoAveragePrice() {
        let summary = CostSummary(fills: [fill(date(2026, 1, 1), 1_000, 40, 0)], services: [], calendar: calendar)
        #expect(summary.averagePricePerLitre == nil)
    }

    @Test func monthsIncludeEmptyOnesUpToNow() {
        let summary = CostSummary(fills: [fill(date(2026, 1, 15), 1_000, 40, 80)], services: [ServiceCost(date: date(2026, 3, 1), cost: 30)], calendar: calendar)
        let months = summary.months(from: nil, to: date(2026, 4, 10))
        #expect(months.map(\.total) == [80, 0, 30, 0])
        #expect(months.first?.fuel == 80)
        #expect(months[2].service == 30)
    }

    @Test(arguments: [
        (ChartRange.threeMonths, 2026, 2),
        (ChartRange.twelveMonths, 2025, 5),
    ])
    func rangesStartAtTheFirstDayOfAMonth(range: ChartRange, year: Int, month: Int) throws {
        let start = try #require(range.start(now: date(2026, 4, 10), calendar: calendar))
        #expect(calendar.dateComponents([.year, .month, .day], from: start) == DateComponents(year: year, month: month, day: 1))
    }

    @Test func allHasNoStartAndContainsEverything() {
        #expect(ChartRange.all.start(now: .now, calendar: calendar) == nil)
        #expect(ChartRange.all.contains(.distantPast, now: .now, calendar: calendar))
    }
}
