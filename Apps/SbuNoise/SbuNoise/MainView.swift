import SbuKit
import SwiftUI

/// The player, the app's one screen. Empty until the catalog arrives; the bottom bar holds
/// White Noise's actions, which open sheets over the player rather than switching tabs.
struct MainView: View {
    var body: some View {
        ContentUnavailableView("Nessun suono", systemImage: "waveform")
            .toolbar {
                ToolbarItemGroup(placement: .bottomBar) {
                    // ponytail: disabled until each action's ticket wires its sheet.
                    Button("Crea", systemImage: "plus") {}
                    Spacer()
                    Button("Gestisci", systemImage: "square.grid.2x2") {}
                    Spacer()
                    Button("Timer", systemImage: "clock") {}
                    Spacer()
                    Button("Dormi", systemImage: "moon") {}
                }
            }
            .disabled(true)
    }
}

#Preview("Light") {
    NavigationStack { MainView() }
}

#Preview("Dark") {
    NavigationStack { MainView() }
        .preferredColorScheme(.dark)
}
