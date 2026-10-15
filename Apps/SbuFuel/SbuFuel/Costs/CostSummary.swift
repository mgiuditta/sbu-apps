import Foundation

/// Spending of one vehicle: per month and year, per kilometre, and the average price of fuel.
nonisolated struct CostSummary: Sendable {
    private let fills: [FillRecord]
    private let services: [ServiceCost]
    private let calendar: Calendar

    init(fills: [FillRecord], services: [ServiceCost], calendar: Calendar) {
        self.fills = fills
        self.services = services
        self.calendar = calendar
    }

    /// Fuel and services in the calendar month of `date`.
    func spent(inMonthOf date: Date) -> Decimal {
        spent { calendar.isDate($0, equalTo: date, toGranularity: .month) }
    }

    /// Fuel and services in the calendar year of `date`.
    func spent(inYearOf date: Date) -> Decimal {
        spent { calendar.isDate($0, equalTo: date, toGranularity: .year) }
    }

    /// Fuel and services together.
    var total: Decimal {
        fuelTotal + serviceTotal
    }

    var fuelTotal: Decimal {
        fills.reduce(0) { $0 + $1.totalPrice }
    }

    var serviceTotal: Decimal {
        services.reduce(0) { $0 + $1.cost }
    }

    /// Fuel spent per kilometre driven: every fuel-up after the first by odometer, over the distance
    /// from the first to the last. The first fill's fuel was burned before the log began.
    var fuelCostPerKm: Decimal? {
        let ordered = fills.sorted { $0.odometerKm < $1.odometerKm }
        guard let first = ordered.first, let last = ordered.last, last.odometerKm > first.odometerKm else { return nil }
        let spent = ordered.dropFirst().reduce(Decimal(0)) { $0 + $1.totalPrice }
        return spent / Decimal(last.odometerKm - first.odometerKm)
    }

    /// The average price of a litre over the paid fuel-ups; free fills do not lower it.
    var averagePricePerLitre: Decimal? {
        let paid = fills.filter { $0.totalPrice > 0 && $0.litres > 0 }
        let litres = paid.reduce(0.0) { $0 + $1.litres }
        guard litres > 0 else { return nil }
        return paid.reduce(Decimal(0)) { $0 + $1.totalPrice } / Decimal(litres)
    }

    /// Every month from the first entry (or `start`) to `now`, empty months included, oldest first.
    func months(from start: Date?, to now: Date) -> [MonthSpend] {
        let dates = fills.map(\.date) + services.map(\.date)
        guard let earliest = start ?? dates.min(),
              var month = calendar.dateInterval(of: .month, for: earliest)?.start,
              let last = calendar.dateInterval(of: .month, for: now)?.start else { return [] }
        var spends: [Date: MonthSpend] = [:]
        for fill in fills {
            guard let key = calendar.dateInterval(of: .month, for: fill.date)?.start else { continue }
            spends[key, default: MonthSpend(month: key)].fuel += fill.totalPrice
        }
        for service in services {
            guard let key = calendar.dateInterval(of: .month, for: service.date)?.start else { continue }
            spends[key, default: MonthSpend(month: key)].service += service.cost
        }
        var result: [MonthSpend] = []
        while month <= last {
            result.append(spends[month] ?? MonthSpend(month: month))
            guard let next = calendar.date(byAdding: .month, value: 1, to: month) else { break }
            month = next
        }
        return result
    }

    private func spent(where matches: (Date) -> Bool) -> Decimal {
        fills.filter { matches($0.date) }.reduce(Decimal(0)) { $0 + $1.totalPrice }
            + services.filter { matches($0.date) }.reduce(Decimal(0)) { $0 + $1.cost }
    }
}
