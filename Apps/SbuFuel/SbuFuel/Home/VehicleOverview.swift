import SbuKit
import SwiftUI

/// The sections of the tool screen for one vehicle.
struct VehicleOverview: View {
    let vehicle: Vehicle
    let units: UnitSettings
    let notifications: ReminderNotifications

    var body: some View {
        let records = vehicle.fillRecords
        let consumption = ConsumptionCalculator(records)
        let costs = CostSummary(fills: records, services: (vehicle.services ?? []).map { ServiceCost(date: $0.date, cost: $0.cost) }, calendar: .current)
        Section {
            ConsumptionFigure(consumption: consumption, hasFuelUps: !records.isEmpty, unit: units.consumption, distanceUnit: vehicle.odometerUnit)
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
        }
        if !consumption.segments.isEmpty {
            ConsumptionSection(consumption: consumption, unit: units.consumption)
        }
        if !records.isEmpty {
            SpendingSection(costs: costs, distanceUnit: vehicle.odometerUnit, volumeUnit: units.volume)
        }
        NextServiceSection(vehicle: vehicle)
        Section {
            NavigationLink {
                HistoryView(vehicle: vehicle, units: units)
            } label: {
                OverviewLink(title: "Storico", systemImage: "list.bullet.rectangle")
            }
            .accessibilityIdentifier("history")
            NavigationLink {
                CostsView(vehicle: vehicle, units: units)
            } label: {
                OverviewLink(title: "Spese e grafici", systemImage: "chart.bar")
            }
            .accessibilityIdentifier("costs")
            NavigationLink {
                ServicesView(vehicle: vehicle, units: units, notifications: notifications)
            } label: {
                OverviewLink(title: "Manutenzione", systemImage: "wrench.and.screwdriver")
            }
            .accessibilityIdentifier("services")
        }
        .listRowBackground(SbuTheme.surfaceRaised)
    }
}
