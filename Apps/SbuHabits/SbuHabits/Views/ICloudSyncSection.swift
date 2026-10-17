import SbuKit
import SwiftUI

/// Impostazioni, Dati: Sincronizza con iCloud, off until you turn it on. Without iCloud the switch
/// stays off and the footer says what to do.
struct ICloudSyncSection: View {
    let sync: HabitsSync

    /// Follows the switch at once; `HabitsSync` catches up after its first merge.
    @State private var isOn: Bool

    init(sync: HabitsSync) {
        self.sync = sync
        _isOn = State(initialValue: sync.isEnabled)
    }

    var body: some View {
        Section {
            Toggle("Sincronizza con iCloud", isOn: $isOn)
                .disabled(sync.isAvailable == false)
        } header: {
            Text("Dati")
        } footer: {
            Text(footer)
        }
        .onChange(of: isOn) { _, on in
            Task {
                await sync.setEnabled(on)
            }
        }
        // iCloud signed out, or another account: the switch goes off by itself.
        .onChange(of: sync.isEnabled) { _, enabled in
            isOn = enabled
        }
    }

    private var footer: LocalizedStringKey {
        if sync.isAvailable == false {
            "Per sincronizzare, accedi a iCloud e attiva iCloud Drive nelle Impostazioni dell'iPhone."
        } else if sync.isNewerOnICloud {
            "Su iCloud ci sono dati di una versione più recente di Sbu Habits. Aggiorna l'app per sincronizzare."
        } else {
            "Le abitudini e lo storico vanno sul tuo iCloud, mai a sbu.dev, e si uniscono a quelli degli altri tuoi dispositivi. Esporta e Importa funzionano come sempre."
        }
    }
}

#Preview("Light") {
    Form {
        ICloudSyncSection(sync: .preview(model: .preview))
        ICloudSyncSection(sync: .preview(model: .preview, isAvailable: false))
    }
    .tint(SbuTheme.ink)
}

#Preview("Dark") {
    Form {
        ICloudSyncSection(sync: .preview(model: .preview))
        ICloudSyncSection(sync: .preview(model: .preview, isAvailable: false))
    }
    .tint(SbuTheme.ink)
    .preferredColorScheme(.dark)
}
