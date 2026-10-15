import SbuKit
import SwiftUI

/// A fuel-up in the history: day, reading and quantity, what it cost, and the consumption of the
/// segment it closes, or why it closes none.
struct FuelUpRow: View {
    let fuelUp: FuelUp
    let segment: ConsumptionSegment?
    let distanceUnit: DistanceUnit
    let units: UnitSettings

    var body: some View {
        EntryRow(
            title: Text(fuelUp.date.formatted(.dateTime.day().month(.wide).year())),
            subtitle: Text(distanceUnit.formatted(km: fuelUp.odometerKm) + " · " + units.volume.formatted(litres: fuelUp.litres)),
            systemImage: "fuelpump",
            amount: fuelUp.totalPrice.formatted(.currency(code: fuelUp.currencyCode)),
            status: status
        )
    }

    private var status: Text {
        if let segment {
            return Text(units.consumption.formatted(kmPerLitre: segment.kmPerLitre) + "\u{00A0}" + units.consumption.symbol)
        }
        if !fuelUp.isFull { return Text("Parziale") }
        if fuelUp.missedPrevious { return Text("Dopo un salto") }
        return Text("Pieno")
    }
}

#Preview("Light") {
    List {
        FuelUpRow(fuelUp: FuelUp(vehicle: nil, date: .now, odometerKm: 45_210, litres: 38.4, totalPrice: 68.7, currencyCode: "EUR"),
                  segment: nil, distanceUnit: .kilometres, units: UnitSettings())
    }
}

#Preview("Dark") {
    List {
        FuelUpRow(fuelUp: FuelUp(vehicle: nil, date: .now, odometerKm: 45_210, litres: 18.4, totalPrice: 0, currencyCode: "EUR", isFull: false),
                  segment: nil, distanceUnit: .kilometres, units: UnitSettings())
    }
    .preferredColorScheme(.dark)
}
