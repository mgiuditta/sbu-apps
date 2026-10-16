import SbuKit
import SwiftUI

/// One saved TV: its name (editable), system, address, model and MAC, and the way to forget it.
struct SavedTVDetailView: View {
    let tv: SavedTV
    let session: RemoteSession

    @Environment(\.dismiss) private var dismiss
    @State private var name = ""

    var body: some View {
        List {
            Section {
                TextField("Nome", text: $name)
                    .submitLabel(.done)
                    .onSubmit(rename)
            } header: {
                Text("Nome")
            }
            .listRowBackground(SbuTheme.surfaceRaised)

            Section {
                LabeledContent("Sistema", value: tv.brand.displayName)
                LabeledContent("Indirizzo IP", value: tv.host)
                if let model = tv.model {
                    LabeledContent("Modello", value: model)
                }
                LabeledContent("Indirizzo MAC") {
                    Text(tv.macAddress ?? String(localized: "Sconosciuto"))
                }
            }
            .listRowBackground(SbuTheme.surfaceRaised)

            Section {
                Text(PairingGuide.powerOn(tv.brand))
                    .font(SbuTheme.body)
                    .foregroundStyle(SbuTheme.ink)
            } header: {
                Text("Accensione")
            } footer: {
                Text("Via Wi-Fi l'accensione può non riuscire: con il cavo di rete è più affidabile.")
            }
            .listRowBackground(SbuTheme.surfaceRaised)

            Section {
                SbuButton("Dimentica questa TV", kind: .destructive, confirmationTitle: "Dimenticare \(tv.name)?", action: forget)
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
            } footer: {
                Text("Per usarla di nuovo dovrai collegarla da capo.")
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(SbuTheme.surface)
        .navigationTitle(tv.name)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { name = tv.name }
        .onDisappear(perform: rename)
    }

    private func rename() {
        session.store.rename(tv, to: name)
    }

    private func forget() {
        Task {
            await session.forget(tv)
            dismiss()
        }
    }
}

#Preview("Light") {
    NavigationStack {
        SavedTVDetailView(tv: .sample, session: RemoteSession(store: TVStore(defaults: UserDefaults(suiteName: "preview") ?? .standard)))
    }
    .tint(SbuTheme.accentRemote)
}

#Preview("Dark") {
    NavigationStack {
        SavedTVDetailView(tv: .sample, session: RemoteSession(store: TVStore(defaults: UserDefaults(suiteName: "preview") ?? .standard)))
    }
    .tint(SbuTheme.accentRemote)
    .preferredColorScheme(.dark)
}
