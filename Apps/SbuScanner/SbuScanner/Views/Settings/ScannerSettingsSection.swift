import SwiftUI

/// What happens when a code is read.
struct ScannerSettingsSection: View {
    @AppStorage(ScannerSettings.sound) private var playsSound = true
    @AppStorage(ScannerSettings.vibration) private var vibrates = true
    @AppStorage(ScannerSettings.saveHistory) private var savesHistory = true

    var body: some View {
        Section {
            Toggle("Suono", isOn: $playsSound)
            Toggle("Vibrazione", isOn: $vibrates)
            Toggle("Salva nella cronologia", isOn: $savesHistory)
        } header: {
            Text("Lettura")
        } footer: {
            Text("La cronologia resta solo su questo iPhone. Senza, ogni codice letto si vede una volta e basta.")
        }
    }
}

#Preview("Light") {
    Form { ScannerSettingsSection() }
}

#Preview("Dark") {
    Form { ScannerSettingsSection() }
        .preferredColorScheme(.dark)
}
