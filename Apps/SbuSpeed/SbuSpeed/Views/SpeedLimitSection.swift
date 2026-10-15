import SbuKit
import SwiftUI

/// Settings section to choose a speed limit, or none, in the current unit: the presets,
/// or any whole value through Altro valore.
struct SpeedLimitSection: View {
    @Bindable var model: SpeedModel

    @State private var isEnteringValue = false
    @State private var typedValue = ""

    /// The presets, plus the current limit when it is a value typed in Altro valore.
    private var choices: [SpeedLimit] {
        let presets = SpeedLimit.presets(for: model.unit)
        guard let limit = model.speedLimit, !presets.contains(limit) else { return presets }
        return (presets + [limit]).sorted { $0.value < $1.value }
    }

    private var highestValue: Int { SpeedLimit.highestValue(for: model.unit) }

    var body: some View {
        Section {
            Picker("Limite", selection: $model.speedLimit) {
                Text("Nessuno")
                    .tag(SpeedLimit?.none)

                ForEach(choices, id: \.self) { limit in
                    Text(verbatim: limit.text())
                        .tag(Optional(limit))
                }
            }

            Button("Altro valore", action: enterValue)
                .alert("Altro valore", isPresented: $isEnteringValue) {
                    TextField("Limite", text: $typedValue)
                        .keyboardType(.numberPad)
                    Button("Imposta", action: setTypedValue)
                    Button("Annulla", role: .cancel) {}
                } message: {
                    Text("Da \(SpeedLimit.lowestValue) a \(highestValue) \(model.unit.symbol).")
                }
        } header: {
            Text("Limite di velocità")
        } footer: {
            Text("Quando lo superi, l'iPhone vibra e suona una volta.")
        }
    }

    private func enterValue() {
        typedValue = model.speedLimit.map { String($0.value) } ?? ""
        isEnteringValue = true
    }

    private func setTypedValue() {
        if let limit = SpeedLimit.custom(typedValue, unit: model.unit) {
            model.speedLimit = limit
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
