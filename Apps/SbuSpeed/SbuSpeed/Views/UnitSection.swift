import SbuKit
import SwiftUI

/// Settings section to choose km/h, mph or knots.
struct UnitSection: View {
    @Bindable var model: SpeedModel

    var body: some View {
        Section {
            Picker("Velocità", selection: $model.unit) {
                ForEach(SpeedUnit.allCases) { unit in
                    Text(unit.name)
                        .tag(unit)
                }
            }
            // Three rows with a check, not a menu: the names never get cut at large text sizes.
            .pickerStyle(.inline)
            .labelsHidden()
        } header: {
            Text("Unità")
        } footer: {
            Text("La distanza segue la velocità: chilometri, miglia o miglia nautiche.")
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
