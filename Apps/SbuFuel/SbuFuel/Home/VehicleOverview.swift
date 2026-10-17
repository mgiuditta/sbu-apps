import SbuKit
import SwiftData
import SwiftUI

/// The cards of the tool screen under the figure, for one vehicle: the way into the log, the next
/// service, then the secondary figures.
struct VehicleOverview: View {
    let vehicle: Vehicle
    let units: UnitSettings
    let notifications: ReminderNotifications

    var body: some View {
        let records = vehicle.fillRecords
        let consumption = ConsumptionCalculator(records)
        VStack(alignment: .leading, spacing: SbuTheme.space6) {
            SbuListCard(OverviewDestination.allCases) { destination in
                NavigationLink {
                    view(for: destination)
                } label: {
                    OverviewLink(destination: destination)
                }
                // The link is the whole row: the card's own padding goes inside its 44 pt target.
                .padding(.vertical, -SbuTheme.space3)
                .accessibilityIdentifier(destination.id)
            }
            NextServiceSection(vehicle: vehicle)
            if !consumption.segments.isEmpty {
                ConsumptionSection(consumption: consumption, unit: units.consumption)
            }
            if !records.isEmpty {
                let costs = CostSummary(fills: records, services: (vehicle.services ?? []).map { ServiceCost(date: $0.date, cost: $0.cost) },
                                        calendar: .current)
                SpendingSection(costs: costs, distanceUnit: vehicle.odometerUnit, volumeUnit: units.volume)
            }
        }
    }

    @ViewBuilder
    private func view(for destination: OverviewDestination) -> some View {
        switch destination {
        case .history: HistoryView(vehicle: vehicle, units: units)
        case .costs: CostsView(vehicle: vehicle, units: units)
        case .services: ServicesView(vehicle: vehicle, units: units, notifications: notifications)
        }
    }
}

#Preview("Light") {
    VehicleOverviewPreview()
        .modelContainer(.preview)
}

#Preview("Dark") {
    VehicleOverviewPreview()
        .modelContainer(.preview)
        .preferredColorScheme(.dark)
}

private struct VehicleOverviewPreview: View {
    @Query private var vehicles: [Vehicle]

    var body: some View {
        NavigationStack {
            ScrollView {
                if let vehicle = vehicles.first {
                    VehicleOverview(vehicle: vehicle, units: UnitSettings(), notifications: ReminderNotifications(center: SilentReminderCenter()))
                        .padding(SbuTheme.space4)
                }
            }
            .background(SbuTheme.paper)
        }
        .tint(SbuTheme.ink)
    }
}
