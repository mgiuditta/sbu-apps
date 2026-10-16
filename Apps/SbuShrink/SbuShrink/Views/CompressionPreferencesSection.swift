import SbuKit
import SwiftUI

/// The app's own settings, above the sbu.dev promise: the album, and the way back to the
/// suggested values after trying the sliders.
struct CompressionPreferencesSection: View {
    @Bindable var model: ShrinkModel

    var body: some View {
        Section {
            Toggle("Salva anche nell'album Video compressi", isOn: $model.savesToAlbum)
        } header: {
            Text("Album")
        } footer: {
            Text("Le copie vanno sempre nella libreria di Foto, con la data e il luogo dell'originale.")
        }

        Section {
            SbuButton(
                "Ripristina le impostazioni consigliate",
                kind: .destructive,
                confirmationTitle: "Ripristinare le impostazioni consigliate?",
                action: model.restoreSuggestedSettings
            )
            .disabled(model.settings == CompressionSettings())
            .listRowInsets(EdgeInsets())
            .listRowBackground(Color.clear)
        } footer: {
            Text("Frame rate 24, dimensioni 80%, qualità 60%, Avanzate spente.")
        }
    }
}

#Preview("Light") {
    List {
        CompressionPreferencesSection(model: .preview())
    }
    .tint(SbuTheme.accentShrink)
}

#Preview("Dark") {
    List {
        CompressionPreferencesSection(model: .preview())
    }
    .tint(SbuTheme.accentShrink)
    .preferredColorScheme(.dark)
}
