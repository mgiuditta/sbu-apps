import SbuKit
import SwiftUI

/// Settings: the rules and the highlights, all on as in the original.
struct GameSettingsSection: View {
    @Bindable var store: GameStore

    var body: some View {
        Section {
            Toggle("Tre errori e la partita finisce", isOn: $store.preferences.hasMistakeLimit)
            Toggle("Segna gli errori", isOn: $store.preferences.rules.checksMistakes)
            Toggle("Togli le note quando scrivi una cifra", isOn: $store.preferences.rules.removesNotes)
            Toggle("Evidenzia i doppioni", isOn: $store.preferences.highlightsDuplicates)
            Toggle("Evidenzia riga, colonna e riquadro", isOn: $store.preferences.highlightsAreas)
            Toggle("Evidenzia le cifre uguali", isOn: $store.preferences.highlightsSameDigits)
            Toggle("Nascondi le cifre finite", isOn: $store.preferences.disablesUsedDigits)
            Toggle("Mostra il tempo", isOn: $store.preferences.showsTimer)
        } header: {
            Text("Partita")
        } footer: {
            Text("Il limite di errori vale dall'inizio della partita: a partita iniziata puoi solo toglierlo.")
        }
    }
}

#Preview("Light") {
    List { GameSettingsSection(store: GameStore(defaults: UserDefaults(suiteName: "preview.settings")!)) }
}

#Preview("Dark") {
    List { GameSettingsSection(store: GameStore(defaults: UserDefaults(suiteName: "preview.settings")!)) }
        .preferredColorScheme(.dark)
}
