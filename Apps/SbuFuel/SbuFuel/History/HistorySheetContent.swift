import SwiftData
import SwiftUI

/// The form a `HistorySheet` stands for.
struct HistorySheetContent: View {
    let sheet: HistorySheet
    let vehicle: Vehicle
    let units: UnitSettings
    var notifications: ReminderNotifications?

    var body: some View {
        switch sheet {
        case .newFuelUp: FuelUpForm(vehicle: vehicle, fuelUp: nil, units: units)
        case let .fuelUp(fuelUp): FuelUpForm(vehicle: vehicle, fuelUp: fuelUp, units: units)
        case .newService: ServiceForm(vehicle: vehicle, service: nil)
        case let .service(service): ServiceForm(vehicle: vehicle, service: service)
        case .newReminder: ReminderForm(vehicle: vehicle, reminder: nil, notifications: notifications)
        case let .reminder(reminder): ReminderForm(vehicle: vehicle, reminder: reminder, notifications: notifications)
        }
    }
}

#Preview("Light") {
    HistorySheetPreview()
        .modelContainer(.preview)
}

#Preview("Dark") {
    HistorySheetPreview()
        .modelContainer(.preview)
        .preferredColorScheme(.dark)
}

private struct HistorySheetPreview: View {
    @Query private var vehicles: [Vehicle]

    var body: some View {
        if let vehicle = vehicles.first {
            HistorySheetContent(sheet: .newService, vehicle: vehicle, units: UnitSettings())
        }
    }
}
