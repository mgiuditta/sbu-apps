import SbuKit
import SwiftUI

/// The empty state of the first launch: add your vehicle, or look around with a sample one.
struct FirstVehicleView: View {
    let addVehicle: () -> Void
    let addSample: () -> Void

    var body: some View {
        ContentUnavailableView {
            Label("Aggiungi il tuo veicolo", systemImage: "car")
        } description: {
            Text("Poi registra i rifornimenti: dal secondo pieno vedi quanto consuma.")
        } actions: {
            VStack(spacing: SbuTheme.space3) {
                SbuButton("Aggiungi veicolo", action: addVehicle)
                    .accessibilityIdentifier("addFirstVehicle")
                SbuButton("Prova con dati di esempio", kind: .secondary, action: addSample)
                    .accessibilityIdentifier("addSample")
            }
            .padding(.horizontal, SbuTheme.space4)
        }
    }
}

#Preview("Light") {
    FirstVehicleView(addVehicle: {}, addSample: {})
        .background(SbuTheme.surface)
        .tint(SbuTheme.accentFuel)
}

#Preview("Dark") {
    FirstVehicleView(addVehicle: {}, addSample: {})
        .background(SbuTheme.surface)
        .tint(SbuTheme.accentFuel)
        .preferredColorScheme(.dark)
}
