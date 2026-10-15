import SbuKit
import SwiftUI

/// Settings → how consumption and fuel quantities are shown.
struct UnitsSection: View {
    @Bindable var units: UnitSettings

    var body: some View {
        Section {
            Picker("Consumo", selection: $units.consumption) {
                ForEach(ConsumptionUnit.allCases) { unit in
                    Text(unit.name).tag(unit)
                }
            }
            .accessibilityIdentifier("consumptionUnit")
            Picker("Quantità", selection: $units.volume) {
                ForEach(VolumeUnit.allCases) { unit in
                    Text(unit.name).tag(unit)
                }
            }
            .accessibilityIdentifier("volumeUnit")
        } header: {
            Text("Unità")
        } footer: {
            Text("I chilometri o le miglia li scegli per ogni veicolo. Cambiare unità non cambia i dati salvati.")
        }
    }
}

#Preview("Light") {
    List {
        UnitsSection(units: UnitSettings())
    }
}

#Preview("Dark") {
    List {
        UnitsSection(units: UnitSettings())
    }
    .preferredColorScheme(.dark)
}
