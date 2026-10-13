import SbuKit
import SwiftUI

/// Settings section to choose km/h, mph or knots.
struct UnitSection: View {
    @Bindable var model: SpeedModel

    var body: some View {
        Section {
            Picker("Velocità", selection: $model.unit) {
                ForEach(SpeedUnit.allCases) { unit in
                    Text(verbatim: unit.symbol)
                        .tag(unit)
                }
            }
        } header: {
            Text("Unità")
        } footer: {
            Text("La distanza segue la velocità: chilometri con km/h, miglia con mph, miglia nautiche con i nodi.")
        }
    }
}

#Preview("Light") {
    Form {
        UnitSection(model: SpeedModel())
    }
}

#Preview("Dark") {
    Form {
        UnitSection(model: SpeedModel())
    }
    .preferredColorScheme(.dark)
}
