import Foundation
import SwiftData

/// A service done on a vehicle: oil, tyres, inspection, tax, or anything you name.
@Model
final class ServiceEntry {
    var id = UUID()
    var vehicle: Vehicle?
    var kindRaw = ServiceKind.custom.rawValue
    var title = ""
    var date = Date.now
    var odometerKm: Double?
    var cost: Decimal = 0
    var currencyCode = "EUR"
    var note = ""

    init(vehicle: Vehicle?, kind: ServiceKind, title: String, date: Date, odometerKm: Double?, cost: Decimal, currencyCode: String, note: String = "") {
        self.vehicle = vehicle
        kindRaw = kind.rawValue
        self.title = title
        self.date = date
        self.odometerKm = odometerKm
        self.cost = cost
        self.currencyCode = currencyCode
        self.note = note
    }

    var kind: ServiceKind {
        get { ServiceKind(rawValue: kindRaw) ?? .custom }
        set { kindRaw = newValue.rawValue }
    }
}
