import SbuKit
import SwiftUI

/// Settings section for the lock: whether it waits for a steady reading, and how steady.
struct LockSection: View {
    @Bindable var model: LevelModel

    private var tolerance: String {
        "±" + Measurement(value: model.steadyTolerance, unit: UnitAngle.degrees)
            .formatted(.measurement(width: .narrow, usage: .asProvided, numberFormatStyle: .number.precision(.fractionLength(1))))
    }

    var body: some View {
        Section {
            Toggle("Blocca a lettura stabile", isOn: $model.locksWhenSteady)

            if model.locksWhenSteady {
                VStack(alignment: .leading, spacing: SbuTheme.space2) {
                    LabeledContent("Tolleranza") {
                        Text(verbatim: tolerance)
                            .monospacedDigit()
                            .foregroundStyle(SbuTheme.inkMuted)
                    }

                    Slider(value: $model.steadyTolerance, in: SteadyLock.toleranceRange, step: SteadyLock.toleranceStep) {
                        Text("Tolleranza")
                    }
                    .accessibilityValue(Text(verbatim: tolerance))
                }
            }

            // iOS hands the volume buttons to an app only from 17.2, and only while the camera runs.
            if VolumeButtonTrigger.isSupported {
                Toggle("Blocca col tasto volume nel mirino", isOn: $model.locksWithVolumeButton)
            }
        } header: {
            Text("Blocco")
        } footer: {
            Text("Dopo Blocca, la lettura si ferma quando resta entro la tolleranza per due secondi, e mostra la media. Nel mirino, con la fotocamera accesa, anche un tasto volume blocca e sblocca.")
        }
    }
}

#Preview("Light") {
    List {
        LockSection(model: LevelModel(source: FixedGravitySource.screenshot))
    }
}

#Preview("Dark") {
    List {
        LockSection(model: LevelModel(source: FixedGravitySource.screenshot))
    }
    .preferredColorScheme(.dark)
}
