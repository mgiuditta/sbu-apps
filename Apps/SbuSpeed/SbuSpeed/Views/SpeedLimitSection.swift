import SbuKit
import SwiftUI

/// Settings section to choose a speed limit, or none, in the current unit.
struct SpeedLimitSection: View {
    @Bindable var model: SpeedModel

    var body: some View {
        Section {
            Picker("Limite", selection: $model.speedLimit) {
                Text("Nessuno")
                    .tag(SpeedLimit?.none)

                ForEach(SpeedLimit.presets(for: model.unit), id: \.self) { limit in
                    Text(verbatim: limit.text())
                        .tag(Optional(limit))
                }
            }
        } header: {
            Text("Limite di velocità")
        } footer: {
            Text("Quando lo superi, l'iPhone vibra e suona una volta.")
        }
    }
}

#Preview("Light") {
    Form {
        SpeedLimitSection(model: SpeedModel())
    }
}

#Preview("Dark") {
    Form {
        SpeedLimitSection(model: SpeedModel())
    }
    .preferredColorScheme(.dark)
}
