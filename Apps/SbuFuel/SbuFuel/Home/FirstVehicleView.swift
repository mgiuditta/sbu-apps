import SbuKit
import SwiftUI

/// The empty state of the first launch: add your vehicle, or look around with a sample one.
/// The sample stays as a second button: it is the one way to see the figure before two real fill-ups.
struct FirstVehicleView: View {
    let addVehicle: () -> Void
    let addSample: () -> Void

    var body: some View {
        SbuEmpty(sentence: "Aggiungi il tuo veicolo: dal secondo pieno vedi quanto consuma.") {
            VStack(spacing: SbuTheme.space3) {
                SbuButton("Aggiungi veicolo", action: addVehicle)
                    .accessibilityIdentifier("addFirstVehicle")
                SbuButton("Prova con dati di esempio", kind: .secondary, action: addSample)
                    .accessibilityIdentifier("addSample")
            }
        }
    }
}

#Preview("Light") {
    FirstVehicleView(addVehicle: {}, addSample: {})
        .padding(SbuTheme.space4)
        .frame(maxHeight: .infinity, alignment: .top)
        .sbuPaper(grid: true)
}

#Preview("Dark") {
    FirstVehicleView(addVehicle: {}, addSample: {})
        .padding(SbuTheme.space4)
        .frame(maxHeight: .infinity, alignment: .top)
        .sbuPaper(grid: true)
        .preferredColorScheme(.dark)
}
