import SbuKit
import SwiftUI

/// Focus, as in SocialLite: the apps chosen in Blocco close now for the time you pick.
struct FocusCard: View {
    let shield: ShieldModel

    var body: some View {
        VStack(alignment: .leading, spacing: SbuTheme.space2) {
            if let end = shield.focusEnd {
                Text("Focus fino alle \(end, format: .dateTime.hour().minute())")
                Button("Termina il focus", action: shield.endFocus)
            } else {
                Menu("Inizia un focus") {
                    ForEach(ShieldSettings.focusLengths, id: \.self) { minutes in
                        Button {
                            shield.startFocus(minutes: minutes)
                        } label: {
                            Text(Duration.seconds(minutes * 60), format: .units(allowed: [.hours, .minutes], width: .wide))
                        }
                    }
                }
                Text("Le app scelte in Blocco si chiudono per il tempo che scegli.")
                    .font(SbuTheme.footnote)
                    .foregroundStyle(SbuTheme.inkMuted)
            }
        }
        .font(SbuTheme.body)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(SbuTheme.space4)
        .background(SbuTheme.surfaceRaised, in: .rect(cornerRadius: SbuTheme.radiusCard))
        .overlay {
            RoundedRectangle(cornerRadius: SbuTheme.radiusCard)
                .strokeBorder(SbuTheme.line, lineWidth: SbuTheme.hairline)
        }
    }
}

#Preview("Light") {
    FocusCard(shield: ShieldModel(defaults: UserDefaults(suiteName: "preview")!))
        .padding()
}

#Preview("Dark") {
    FocusCard(shield: ShieldModel(defaults: UserDefaults(suiteName: "preview")!))
        .padding()
        .preferredColorScheme(.dark)
}
