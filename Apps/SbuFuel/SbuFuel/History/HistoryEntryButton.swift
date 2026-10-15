import SbuKit
import SwiftUI

/// One history row: a button that opens its form, with a swipe to delete.
struct HistoryEntryButton: View {
    let entry: HistoryEntry
    let segment: ConsumptionSegment?
    let distanceUnit: DistanceUnit
    let units: UnitSettings
    let open: (HistoryEntry) -> Void
    let delete: (HistoryEntry) -> Void

    var body: some View {
        Button(action: tap) {
            switch entry {
            case let .fuel(fuelUp):
                FuelUpRow(fuelUp: fuelUp, segment: segment, distanceUnit: distanceUnit, units: units)
            case let .service(service):
                ServiceRow(service: service, distanceUnit: distanceUnit)
            }
        }
        .buttonStyle(.plain)
        .swipeActions {
            Button("Elimina", systemImage: "trash", role: .destructive, action: swipeDelete)
        }
        .accessibilityAction(named: Text("Elimina"), swipeDelete)
    }

    private func tap() {
        open(entry)
    }

    private func swipeDelete() {
        delete(entry)
    }
}

#Preview("Light") {
    List {
        HistoryEntryButton(entry: .service(ServiceEntry(vehicle: nil, kind: .tax, title: "Bollo", date: .now, odometerKm: nil, cost: 212, currencyCode: "EUR")),
                           segment: nil, distanceUnit: .kilometres, units: UnitSettings(), open: { _ in }, delete: { _ in })
    }
}

#Preview("Dark") {
    List {
        HistoryEntryButton(entry: .service(ServiceEntry(vehicle: nil, kind: .tax, title: "Bollo", date: .now, odometerKm: nil, cost: 212, currencyCode: "EUR")),
                           segment: nil, distanceUnit: .kilometres, units: UnitSettings(), open: { _ in }, delete: { _ in })
    }
    .preferredColorScheme(.dark)
}
