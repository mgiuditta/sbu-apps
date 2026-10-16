import SbuKit
import SwiftUI

/// Short answers in settings: photos and videos through AirPlay (#353), and Local Network.
struct HelpSection: View {
    var body: some View {
        Section {
            Label {
                Text("Per vedere foto e video sulla TV usa AirPlay, da Foto o dal Centro di Controllo, se la TV lo supporta.")
                    .font(SbuTheme.body)
                    .foregroundStyle(SbuTheme.ink)
            } icon: {
                Image(systemName: "airplayvideo")
                    .fontWeight(.medium)
            }
            Label {
                Text("Se Sbu Remote non trova la TV, controlla che Rete locale sia attiva in Impostazioni › Privacy e sicurezza.")
                    .font(SbuTheme.body)
                    .foregroundStyle(SbuTheme.ink)
            } icon: {
                Image(systemName: "wifi")
                    .fontWeight(.medium)
            }
        } header: {
            Text("Aiuto")
        } footer: {
            Text("Sbu Remote parla solo con la tua TV, sulla rete di casa. Nessun dato esce dal telefono.")
        }
    }
}
