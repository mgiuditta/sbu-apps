import SbuKit
import SwiftUI

/// The most urgent service reminder of the vehicle, if it has any.
struct NextServiceSection: View {
    let vehicle: Vehicle

    var body: some View {
        if let next = vehicle.sortedReminders().first {
            Section("Prossimo intervento") {
                ReminderRow(reminder: next.reminder, due: next.due, distanceUnit: vehicle.odometerUnit)
            }
        }
    }
}

#Preview("Light") {
    List {
        NextServiceSection(vehicle: Vehicle(name: "Panda"))
    }
}

#Preview("Dark") {
    List {
        NextServiceSection(vehicle: Vehicle(name: "Panda"))
    }
    .preferredColorScheme(.dark)
}
