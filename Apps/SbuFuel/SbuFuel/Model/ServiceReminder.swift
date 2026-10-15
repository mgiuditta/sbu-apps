import Foundation
import SwiftData

/// A service that comes back every so many kilometres, months, or both, whichever comes first.
@Model
final class ServiceReminder {
    /// Also the identifier of its notifications.
    var id = UUID()
    var vehicle: Vehicle?
    var kindRaw = ServiceKind.custom.rawValue
    var title = ""
    var everyKm: Double?
    var everyMonths: Int?
    var lastDoneDate = Date.now
    var lastDoneOdometerKm: Double?

    init(vehicle: Vehicle?, kind: ServiceKind, title: String, everyKm: Double?, everyMonths: Int?, lastDoneDate: Date, lastDoneOdometerKm: Double?) {
        self.vehicle = vehicle
        kindRaw = kind.rawValue
        self.title = title
        self.everyKm = everyKm
        self.everyMonths = everyMonths
        self.lastDoneDate = lastDoneDate
        self.lastDoneOdometerKm = lastDoneOdometerKm
    }

    var kind: ServiceKind {
        get { ServiceKind(rawValue: kindRaw) ?? .custom }
        set { kindRaw = newValue.rawValue }
    }

    var rule: ReminderRule {
        ReminderRule(everyKm: everyKm, everyMonths: everyMonths, lastDoneDate: lastDoneDate, lastDoneOdometerKm: lastDoneOdometerKm)
    }
}
