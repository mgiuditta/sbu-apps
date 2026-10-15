import SbuKit
import SwiftUI

/// Settings section for reading the figure aloud.
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
        } footer: {
            Text("La voce dell'iPhone legge la cifra e ogni blocco, così allinei senza guardare lo schermo. Funziona senza rete.")
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
