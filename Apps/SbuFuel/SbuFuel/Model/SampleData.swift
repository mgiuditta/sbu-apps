import Foundation
import SwiftData

/// "Prova con dati di esempio": one made-up car with eight months of fuel-ups, services and
/// reminders, so the figure, the history and the charts show at once. You delete it like any vehicle.
enum SampleData {
    /// Kilometres between fuel-ups and litres per 100 km for each one, fixed so screenshots never change.
    private static let legs: [(km: Double, consumption: Double, days: Int, full: Bool)] = [
        (0, 0, 0, true), (612, 6.1, 16, true), (575, 6.4, 15, true), (310, 6.0, 9, false), (290, 5.9, 8, true),
        (640, 5.8, 17, true), (598, 6.6, 16, true), (620, 6.2, 18, true), (560, 5.7, 14, true), (605, 6.0, 16, true),
        (590, 6.3, 15, true), (630, 5.9, 17, true), (585, 6.1, 15, true),
    ]

    /// How the pump price moves from one fuel-up to the next, around the base price.
    private static let priceFactors = [1.0, 0.98, 1.02, 1.03, 0.99, 0.97, 1.01, 1.04, 1.02, 0.98, 0.96, 0.99, 1.01]

    static func insert(into context: ModelContext, locale: Locale, now: Date = .now, calendar: Calendar = .current) {
        let currency = locale.currency?.identifier ?? "EUR"
        // A plausible pump price in the phone's currency, per litre.
        let pricePerLitre: Decimal = currency == "USD" ? 1.02 : currency == "GBP" ? 1.42 : 1.79
        let distanceUnit = DistanceUnit.preferred(for: locale)
        let vehicle = Vehicle(name: String(localized: "Auto di esempio"), kind: .car, fuelType: .petrol, odometerUnit: distanceUnit)
        vehicle.tankLitres = 40
        context.insert(vehicle)

        let totalDays = legs.reduce(0) { $0 + $1.days }
        var date = calendar.date(byAdding: .day, value: -totalDays - 2, to: now) ?? now
        var odometer = 41_230.0
        var oilDate = date
        var oilOdometer = odometer
        for (index, leg) in legs.enumerated() {
            date = calendar.date(byAdding: .day, value: leg.days, to: date) ?? date
            odometer += leg.km
            let litres = index == 0 ? 32.0 : (leg.km * leg.consumption / 100 * 100).rounded() / 100
            let pumpPrice = FuelUpDraft.rounded(pricePerLitre * Decimal(priceFactors[index % priceFactors.count]), scale: 3)
            let price = FuelUpDraft.rounded(pumpPrice * Decimal(litres), scale: 2)
            context.insert(FuelUp(vehicle: vehicle, date: date, odometerKm: odometer, litres: litres, totalPrice: price,
                                  currencyCode: currency, isFull: leg.full))
            if index == 5 {
                oilDate = calendar.date(byAdding: .day, value: 2, to: date) ?? date
                oilOdometer = odometer + 40
                context.insert(ServiceEntry(vehicle: vehicle, kind: .oilChange, title: String(localized: "Cambio olio"), date: oilDate,
                                            odometerKm: oilOdometer, cost: currency == "EUR" ? 89 : 79, currencyCode: currency))
            }
        }
        context.insert(ServiceReminder(vehicle: vehicle, kind: .oilChange, title: String(localized: "Cambio olio"), everyKm: distanceUnit == .miles ? DistanceUnit.miles.km(from: 9_500) : 15_000, everyMonths: 12,
                                       lastDoneDate: oilDate, lastDoneOdometerKm: oilOdometer))
        let inspection = calendar.date(byAdding: .day, value: 20 - 365 * 2, to: now) ?? now
        context.insert(ServiceReminder(vehicle: vehicle, kind: .inspection, title: String(localized: "Revisione"), everyKm: nil, everyMonths: 24,
                                       lastDoneDate: inspection, lastDoneOdometerKm: nil))
        try? context.save()
    }
}
