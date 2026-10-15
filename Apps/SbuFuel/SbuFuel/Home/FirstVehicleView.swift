import SbuKit
import SwiftUI

/// The empty state of the first launch: add your vehicle, or look around with a sample one.
/// Not a ContentUnavailableView: its actions are as narrow as their words, and the buttons need the whole width.
struct FirstVehicleView: View {
    let addVehicle: () -> Void
    let addSample: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: SbuTheme.space6) {
                VStack(spacing: SbuTheme.space2) {
                    Image(systemName: "car")
                        .font(.largeTitle)
                        .fontWeight(.medium)
                        .foregroundStyle(SbuTheme.inkMuted)
                        .accessibilityHidden(true)
                    Text("Aggiungi il tuo veicolo")
                        .font(SbuTheme.title2)
                        .foregroundStyle(SbuTheme.ink)
                        .accessibilityAddTraits(.isHeader)
                    Text("Poi registra i rifornimenti: dal secondo pieno vedi quanto consuma.")
                        .font(SbuTheme.body)
                        .foregroundStyle(SbuTheme.inkMuted)
                }
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                VStack(spacing: SbuTheme.space3) {
                    SbuButton("Aggiungi veicolo", action: addVehicle)
                        .accessibilityIdentifier("addFirstVehicle")
                    SbuButton("Prova con dati di esempio", kind: .secondary, action: addSample)
                        .accessibilityIdentifier("addSample")
                }
            }
            .padding(SbuTheme.space4)
            .frame(maxWidth: .infinity)
        }
        .defaultScrollAnchor(.center)
        .scrollBounceBehavior(.basedOnSize)
        .background(SbuTheme.surface)
    }
}

#Preview("Light") {
    FirstVehicleView(addVehicle: {}, addSample: {})
        .tint(SbuTheme.accentFuel)
}

#Preview("Dark") {
    FirstVehicleView(addVehicle: {}, addSample: {})
        .tint(SbuTheme.accentFuel)
        .preferredColorScheme(.dark)
}
