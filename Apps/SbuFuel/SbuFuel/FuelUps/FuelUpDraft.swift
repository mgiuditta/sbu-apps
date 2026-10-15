import Foundation

/// The add and edit form of a fuel-up, as typed: odometer in the vehicle's unit, quantity in the
/// chosen volume, and the price either as the total or per unit; the other one is worked out.
nonisolated struct FuelUpDraft: Equatable, Sendable {
    enum PriceKind: String, CaseIterable, Identifiable, Sendable {
        case total
        case perUnit

        var id: Self { self }
    }

    enum Problem: Equatable, Sendable {
        case missingOdometer
        case missingQuantity
        case conflict(OdometerConflict)
    }

    var date = Date.now
    var odometerText = ""
    var quantityText = ""
    var priceText = ""
    var priceKind = PriceKind.total
    var isFull = true
    var missedPrevious = false
    var station = ""
    var note = ""

    var distanceUnit: DistanceUnit
    var volumeUnit: VolumeUnit
    var locale: Locale

    init(distanceUnit: DistanceUnit, volumeUnit: VolumeUnit, locale: Locale = .current) {
        self.distanceUnit = distanceUnit
        self.volumeUnit = volumeUnit
        self.locale = locale
    }

    /// The form filled from a saved fuel-up, in the units you see.
    init(_ record: FillRecord, station: String, note: String, distanceUnit: DistanceUnit, volumeUnit: VolumeUnit, locale: Locale = .current) {
        self.init(distanceUnit: distanceUnit, volumeUnit: volumeUnit, locale: locale)
        date = record.date
        odometerText = NumberText.text(distanceUnit.value(fromKm: record.odometerKm), fractionDigits: 0...1, locale: locale)
        quantityText = NumberText.text(volumeUnit.value(fromLitres: record.litres), fractionDigits: 0...3, locale: locale)
        priceText = NumberText.text(record.totalPrice, locale: locale)
        isFull = record.isFull
        missedPrevious = record.missedPrevious
        self.station = station
        self.note = note
    }

    var odometerKm: Double? {
        NumberText.double(odometerText, locale: locale).flatMap { $0 > 0 ? distanceUnit.km(from: $0) : nil }
    }

    var quantity: Double? {
        NumberText.double(quantityText, locale: locale).flatMap { $0 > 0 ? $0 : nil }
    }

    var litres: Double? {
        quantity.map(volumeUnit.litres(from:))
    }

    private var price: Decimal? {
        NumberText.decimal(priceText, locale: locale).flatMap { $0 >= 0 ? $0 : nil }
    }

    /// The total paid, rounded to the cent; 0 when the price is left empty.
    var totalPrice: Decimal {
        guard let price else { return 0 }
        switch priceKind {
        case .total: return price
        case .perUnit:
            guard let quantity else { return 0 }
            return Self.rounded(price * Decimal(quantity), scale: 2)
        }
    }

    /// The price per unit, rounded to the tenth of a cent as pumps show it.
    var unitPrice: Decimal? {
        guard let price else { return nil }
        switch priceKind {
        case .perUnit: return price
        case .total:
            guard let quantity else { return nil }
            return Self.rounded(price / Decimal(quantity), scale: 3)
        }
    }

    /// What stops the form from saving, if anything.
    func problem(id: UUID?, among readings: [OdometerReading], calendar: Calendar) -> Problem? {
        guard let odometerKm else { return .missingOdometer }
        guard litres != nil else { return .missingQuantity }
        return OdometerConflict.check(id: id, date: date, km: odometerKm, among: readings, calendar: calendar).map(Problem.conflict)
    }

    /// The fuel-up as the calculators see it, once the form is complete.
    func record(id: UUID = UUID()) -> FillRecord? {
        guard let odometerKm, let litres else { return nil }
        return FillRecord(id: id, date: date, odometerKm: odometerKm, litres: litres, isFull: isFull, missedPrevious: missedPrevious, totalPrice: totalPrice)
    }

    static func rounded(_ value: Decimal, scale: Int) -> Decimal {
        var value = value
        var result = Decimal()
        NSDecimalRound(&result, &value, scale, .plain)
        return result
    }
}
