import SbuKit
import SwiftUI

/// The app's settings: the access to Photos, and starting the swipe over.
struct LibrarySettingsSection: View {
    let model: CleanModel

    @Environment(\.openURL) private var openURL
    @State private var isConfirmingReset = false

    private var accessText: LocalizedStringKey {
        switch model.access {
        case .full: "Tutte le foto"
        case .limited: "Solo quelle scelte"
        case .denied: "Non consentito"
        case .notDetermined: "Da chiedere"
        }
    }

    var body: some View {
        Section {
            LabeledContent("Accesso alle foto") {
                Text(accessText)
            }
            Button("Apri Impostazioni", action: openSettings)
        } header: {
            Text("Libreria")
        } footer: {
            Text("Sbu Clean analizza le foto su questo iPhone. Scarica da iCloud un video solo quando lo chiedi tu, per guardarlo o comprimerlo.")
        }

        Section {
            Button("Ricomincia da capo", role: .destructive) {
                isConfirmingReset = true
            }
            .disabled(model.state.kept.isEmpty && model.state.later.isEmpty)
            .confirmationDialog("Ricomincia da capo", isPresented: $isConfirmingReset, titleVisibility: .visible) {
                Button("Ricomincia da capo", role: .destructive, action: model.resetProgress)
            } message: {
                Text("Le foto che hai tenuto o messo da parte tornano da vedere. Il cestino e le foto da tenere sempre restano.")
            }
        } footer: {
            Text(model.state.kept.isEmpty && model.state.later.isEmpty
                 ? "Quando avrai tenuto o messo da parte delle foto, potrai rivederle da capo."
                 : "I mesi tornano da finire, come la prima volta.")
        }
    }

    private func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            openURL(url)
        }
    }
}

#Preview("Light") {
    List {
        LibrarySettingsSection(model: .preview)
    }
}

#Preview("Dark") {
    List {
        LibrarySettingsSection(model: .preview)
    }
    .preferredColorScheme(.dark)
}
