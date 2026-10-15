import Foundation
import SwiftData

/// One fuel-up, in canonical units: kilometres, litres, and the currency of the phone at entry.
@Model
final class FuelUp {
    var id = UUID()
    var vehicle: Vehicle?
    var date = Date.now
    var odometerKm = 0.0
    var litres = 0.0
    /// 0 is allowed: a free or rewards fill counts in consumption, not in the average price.
    var totalPrice: Decimal = 0
    var currencyCode = "EUR"
    var isFull = true
    var missedPrevious = false
    var station = ""
    var note = ""

    init(vehicle: Vehicle?, date: Date, odometerKm: Double, litres: Double, totalPrice: Decimal, currencyCode: String,
         isFull: Bool = true, missedPrevious: Bool = false, station: String = "", note: String = "") {
        self.vehicle = vehicle
        self.date = date
        self.odometerKm = odometerKm
        self.litres = litres
        self.totalPrice = totalPrice
        self.currencyCode = currencyCode
        self.isFull = isFull
        self.missedPrevious = missedPrevious
        self.station = station
        self.note = note
    }

    var record: FillRecord {
        FillRecord(id: id, date: date, odometerKm: odometerKm, litres: litres, isFull: isFull, missedPrevious: missedPrevious, totalPrice: totalPrice)
    }
}
