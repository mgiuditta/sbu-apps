import SbuKit
import SwiftUI

/// Settings section for what you hear: the figure read aloud, and a sound at each measure.
struct VoiceSection: View {
    @Bindable var model: LevelModel

    var body: some View {
        Section {
            Picker("Leggi ad alta voce", selection: $model.speech) {
                ForEach(SpeechMode.allCases) { mode in
                    Text(mode.name)
                        .tag(mode)
                }
            }
            .pickerStyle(.menu)

            Toggle("Suono alla misura", isOn: $model.playsSound)
        } header: {
            Text("Voce e suono")
        } footer: {
            Text("La voce dell'iPhone legge la cifra e ogni blocco, così allinei senza guardare lo schermo. Il suono segna ogni blocco e ogni passo della calibrazione. Funziona senza rete.")
        }
    }
}

#Preview("Light") {
    List {
        VoiceSection(model: LevelModel(source: FixedGravitySource.screenshot))
    }
}

#Preview("Dark") {
    List {
        VoiceSection(model: LevelModel(source: FixedGravitySource.screenshot))
    }
    .preferredColorScheme(.dark)
}
