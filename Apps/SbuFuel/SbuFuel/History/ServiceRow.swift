import SbuKit
import SwiftUI

/// A service in a list: what was done, when and at which reading, and what it cost.
struct ServiceRow: View {
    let service: ServiceEntry
    let distanceUnit: DistanceUnit

    var body: some View {
        SbuListRow(
            "\(service.title)",
            subtitle: subtitle,
            systemImage: service.kind.systemImage,
            iconBackground: SbuTheme.surfaceSunken,
            iconForeground: SbuTheme.ink,
            amount: service.cost.formatted(.currency(code: service.currencyCode))
        )
    }

    private var subtitle: LocalizedStringKey {
        let date = service.date.formatted(.dateTime.day().month(.abbreviated).year())
        guard let km = service.odometerKm else { return "\(date)" }
        return "\(date) · \(distanceUnit.formatted(km: km))"
    }
}

#Preview("Light") {
    List {
        ServiceRow(service: ServiceEntry(vehicle: nil, kind: .oilChange, title: "Cambio olio", date: .now, odometerKm: 45_250, cost: 89, currencyCode: "EUR"),
                   distanceUnit: .kilometres)
    }
}

#Preview("Dark") {
    List {
        ServiceRow(service: ServiceEntry(vehicle: nil, kind: .tax, title: "Bollo", date: .now, odometerKm: nil, cost: 212, currencyCode: "EUR"),
                   distanceUnit: .kilometres)
    }
    .preferredColorScheme(.dark)
}
