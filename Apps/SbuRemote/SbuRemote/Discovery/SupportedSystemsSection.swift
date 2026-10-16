import SbuKit
import SwiftUI

/// The systems that work and the ones that do not (#362), so nobody waits for a TV that will not show up.
struct SupportedSystemsSection: View {
    var body: some View {
        Section {
            Text("Funziona con Samsung Tizen dal 2016, LG webOS, Android TV e Google TV (Sony, TCL, Philips, Xiaomi, Hisense, Chromecast) e Sony Bravia.")
                .font(SbuTheme.subheadline)
                .foregroundStyle(SbuTheme.inkMuted)
            Text("Non funziona con Fire TV, Hisense VIDAA, Philips senza Android, Roku e Apple TV: per Apple TV usa il telecomando nel Centro di Controllo.")
                .font(SbuTheme.subheadline)
                .foregroundStyle(SbuTheme.inkMuted)
        } header: {
            Text("Quali TV")
        }
        .listRowBackground(SbuTheme.surfaceRaised)
    }
}
