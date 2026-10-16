import SbuKit
import SwiftUI

/// Settings section for the last places: the switch that asks for location, and a way to forget them.
struct PlacesSection: View {
    let model: ScanModel

    @State private var isOn = false
    @State private var isConfirmingForget = false

    var body: some View {
        Section {
            Toggle("Ricorda dove li hai sentiti", isOn: $isOn)

            if model.remembersPlaces {
                if model.placesInBackground {
                    Label("Anche con l'app chiusa, per i tuoi dispositivi", systemImage: "checkmark.circle")
                        .foregroundStyle(SbuTheme.ink)
                } else {
                    Button("Ricorda anche con l'app chiusa", action: allowInBackground)
                }
            }

            if !model.sightings.sightings.isEmpty {
                Button("Cancella le posizioni", role: .destructive, action: confirmForget)
                    .foregroundStyle(SbuTheme.danger)
                    .confirmationDialog("Cancellare tutte le posizioni salvate?", isPresented: $isConfirmingForget, titleVisibility: .visible) {
                        Button("Cancella le posizioni", role: .destructive, action: model.forgetPlaces)
                    }
            }
        } header: {
            Text("Ultima posizione")
        } footer: {
            if model.locationDenied {
                Label("Per ricordare le posizioni, consenti la posizione a Sbu Find in Impostazioni.", systemImage: "location.slash")
            } else {
                Text("Quando un dispositivo non si sente più, Sbu Find salva dov'era il tuo iPhone e te lo mostra sulla mappa. Con l'app chiusa serve la posizione «Sempre», e vale solo per i tuoi dispositivi che trasmettono un servizio Bluetooth. Le posizioni restano su questo iPhone.")
            }
        }
        .onAppear(perform: syncFromModel)
        .onChange(of: isOn, switched)
        .onChange(of: model.remembersPlaces, syncFromModel)
    }

    private func allowInBackground() {
        Task {
            await model.allowPlacesInBackground()
        }
    }

    private func confirmForget() {
        isConfirmingForget = true
    }

    private func syncFromModel() {
        isOn = model.remembersPlaces
    }

    private func switched() {
        guard isOn != model.remembersPlaces else { return }
        let wanted = isOn
        Task {
            await model.setRemembersPlaces(wanted)
            syncFromModel()
        }
    }
}

#Preview("Light") {
    List {
        PlacesSection(model: ScanModel(scanner: FixedScanner(), notifier: AcceptingLostNotifier(), location: FixedLocationProvider()))
    }
}

#Preview("Dark") {
    List {
        PlacesSection(model: ScanModel(scanner: FixedScanner(), notifier: AcceptingLostNotifier(), location: FixedLocationProvider()))
    }
    .preferredColorScheme(.dark)
}
