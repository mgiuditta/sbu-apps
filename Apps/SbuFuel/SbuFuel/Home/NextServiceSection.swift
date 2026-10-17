import SbuKit
import SwiftUI

/// The most urgent service reminder of the vehicle, if it has any.
struct NextServiceSection: View {
    let vehicle: Vehicle

    var body: some View {
        if let next = vehicle.sortedReminders().first {
            CardSection(title: "Prossimo intervento") {
                SbuListCard([next.reminder]) { reminder in
                    ReminderRow(reminder: reminder, due: next.due, distanceUnit: vehicle.odometerUnit)
                }
            }
        }
    }
}

#Preview("Light") {
    NextServiceSection(vehicle: Vehicle(name: "Panda"))
        .padding(SbuTheme.space4)
        .frame(maxHeight: .infinity, alignment: .top)
        .sbuPaper(grid: false)
}

#Preview("Dark") {
    NextServiceSection(vehicle: Vehicle(name: "Panda"))
        .padding(SbuTheme.space4)
        .frame(maxHeight: .infinity, alignment: .top)
        .sbuPaper(grid: false)
        .preferredColorScheme(.dark)
}
