import SbuKit
import SwiftUI

/// The finder's pin: adds the device to I miei dispositivi with a name of your own, or renames
/// and removes it once there.
struct MyDeviceMenu: View {
    let model: ScanModel
    let device: NearbyDevice

    @State private var isNaming = false
    @State private var isConfirmingRemoval = false
    @State private var typedName = ""

    private var saved: SavedDevice? {
        model.savedDevice(forDeviceID: device.id)
    }

    var body: some View {
        Group {
            if let saved {
                // A dialog, not a menu: removing is destructive, and the dialog is its confirmation.
                Button("Il mio dispositivo", systemImage: "pin.fill", action: confirmRemoval)
                    .confirmationDialog(Text(verbatim: saved.name), isPresented: $isConfirmingRemoval, titleVisibility: .visible) {
                        Button("Rinomina", action: startNaming)
                        Button("Togli dai miei dispositivi", role: .destructive, action: remove)
                    }
            } else {
                Button("Aggiungi ai miei dispositivi", systemImage: "pin", action: startNaming)
            }
        }
        .alert(saved == nil ? "Aggiungi ai miei dispositivi" : "Rinomina", isPresented: $isNaming) {
            TextField("Nome", text: $typedName)
            Button("Annulla", role: .cancel) {}
            Button("Salva", action: commitName)
        } message: {
            Text("Resta in cima alla lista, anche quando non lo senti.")
        }
    }

    private func startNaming() {
        typedName = saved?.name ?? device.name ?? ""
        isNaming = true
    }

    private func commitName() {
        if let saved {
            model.renameDevice(saved.id, to: typedName)
        } else {
            model.saveDevice(device, name: typedName)
        }
    }

    private func confirmRemoval() {
        isConfirmingRemoval = true
    }

    private func remove() {
        if let saved {
            model.forgetDevice(saved.id)
        }
    }
}

#Preview("Light") {
    NavigationStack {
        Color.clear
            .toolbar {
                MyDeviceMenu(model: ScanModel(scanner: FixedScanner()), device: NearbyDevice(id: UUID(), name: "Buds Pro", kind: .earbuds, signal: -60, lastSeen: .now))
            }
    }
}

#Preview("Dark") {
    NavigationStack {
        Color.clear
            .toolbar {
                MyDeviceMenu(model: ScanModel(scanner: FixedScanner()), device: NearbyDevice(id: UUID(), name: "Buds Pro", kind: .earbuds, signal: -60, lastSeen: .now))
            }
    }
    .preferredColorScheme(.dark)
}
