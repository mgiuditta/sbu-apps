import SbuKit
import SwiftUI

/// Settings section for the unit of the figure, saved on this iPhone.
struct UnitSection: View {
    @Bindable var model: LevelModel

    var body: some View {
        Section {
            Picker("Unità di misura", selection: $model.unit) {
                ForEach(AngleUnit.allCases) { unit in
                    Text(unit.name)
                        .tag(unit)
                }
            }
            // One row with a menu: the five units inline would push calibration off the sheet, and a
            // pushed list would leave the paper of the settings.
            .pickerStyle(.menu)
        } footer: {
            Text("x:12 è l'alzata su 12 di base, come si legge un tetto. 1V:H è la base per 1 di alzata. Il quadrante resta in gradi.")
        }
    }
}

#Preview("Light") {
    List {
        UnitSection(model: LevelModel(source: FixedGravitySource.screenshot))
    }
}

#Preview("Dark") {
    List {
        UnitSection(model: LevelModel(source: FixedGravitySource.screenshot))
    }
    .preferredColorScheme(.dark)
}
