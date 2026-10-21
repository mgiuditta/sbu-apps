import SbuKit
import SwiftUI

/// The Shield's switch and the way back to the app picker, in a card under the figure.
struct ShieldControls: View {
    @Bindable var shield: ShieldModel
    let pick: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: SbuTheme.space4) {
            Toggle("Schermo attivo", isOn: $shield.isOn)
                .sbuAffectsFigure(shield.isOn)
            Divider()
            Button("Cambia le app", action: pick)
        }
        .font(SbuTheme.body)
        .padding(SbuTheme.space4)
        .background(SbuTheme.surfaceRaised, in: .rect(cornerRadius: SbuTheme.radiusCard))
        .overlay {
            RoundedRectangle(cornerRadius: SbuTheme.radiusCard)
                .strokeBorder(SbuTheme.line, lineWidth: 1)
        }
    }
}

#Preview("Light") {
    ShieldControls(shield: ShieldModel(defaults: UserDefaults(suiteName: "preview")!)) {}
        .padding()
}

#Preview("Dark") {
    ShieldControls(shield: ShieldModel(defaults: UserDefaults(suiteName: "preview")!)) {}
        .padding()
        .preferredColorScheme(.dark)
}
