import SbuKit
import SwiftUI

/// Fai suonare, as in Wunderfind: a growing beep in the Bluetooth headphones still connected to
/// the iPhone, and what it cannot do said plainly.
struct RingCard: View {
    let ringer: HeadphoneRinger

    var body: some View {
        VStack(alignment: .leading, spacing: SbuTheme.space3) {
            if let headphones = ringer.headphones {
                if ringer.isRinging {
                    SbuButton("Ferma il suono", kind: .secondary, action: ringer.stop)
                } else {
                    SbuButton("Fai suonare \(headphones.name)", kind: .secondary, action: ringer.ring)
                }

                Text("Funziona solo con le cuffie ancora collegate all'iPhone, non nella custodia né spente. Il suono parte piano e cresce.")
                    .font(SbuTheme.footnote)
                    .foregroundStyle(SbuTheme.inkMuted)

                if ringer.didFail {
                    Label("Il suono non è partito. Riprova.", systemImage: "exclamationmark.triangle")
                        .font(SbuTheme.footnote)
                        .foregroundStyle(SbuTheme.warning)
                }
            } else {
                Label("Nessuna cuffia collegata all'iPhone: Fai suonare funziona solo con cuffie Bluetooth collegate.", systemImage: "headphones")
                    .font(SbuTheme.footnote)
                    .foregroundStyle(SbuTheme.inkMuted)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview("Light") {
    let audio = FixedAudio()
    RingCard(ringer: HeadphoneRinger(route: audio, player: audio))
        .padding(SbuTheme.space4)
        .background(SbuTheme.surface)
        .tint(SbuTheme.accentFind)
}

#Preview("Dark") {
    let audio = FixedAudio(outputs: [])
    RingCard(ringer: HeadphoneRinger(route: audio, player: audio))
        .padding(SbuTheme.space4)
        .background(SbuTheme.surface)
        .tint(SbuTheme.accentFind)
        .preferredColorScheme(.dark)
}
