import Foundation

/// The form the history or the services screen has open.
enum HistorySheet: Identifiable {
    case newFuelUp
    case fuelUp(FuelUp)
    case newService
    case service(ServiceEntry)
    case newReminder
    case reminder(ServiceReminder)

    var id: String {
        switch self {
        case .newFuelUp: "newFuelUp"
        case let .fuelUp(fuelUp): "fuelUp-\(fuelUp.id)"
        case .newService: "newService"
        case let .service(service): "service-\(service.id)"
        case .newReminder: "newReminder"
        case let .reminder(reminder): "reminder-\(reminder.id)"
        }
    }
}
