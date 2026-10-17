import SbuKit
import SwiftUI

/// Parabrezza: the figure and its unit mirrored left to right, light on the warm black of the dark
/// scheme, to lie on the dashboard at night and read in the windshield. The only dark screen of
/// Sbu (ADR-0011). Full brightness while it shows; a tap anywhere goes back. VoiceOver reads the
/// speed as usual, unmirrored.
struct HUDView: View {
    let model: SpeedModel
    let exit: () -> Void

    @Environment(\.scenePhase) private var scenePhase
    @State private var brightness = ScreenBrightness()

    var body: some View {
        ZStack {
            // The whole screen is the way out, a large target for a hand on the wheel.
            Button(action: exit) {
                SbuTheme.paper
                    .contentShape(.rect)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Esci dal parabrezza")
            .accessibilitySortPriority(0)

            HUDFigure(model: model)
                .allowsHitTesting(false)
                .accessibilitySortPriority(1)
        }
        .ignoresSafeArea()
        // VoiceOver stays on the HUD, never on the tool screen under it.
        .accessibilityElement(children: .contain)
        .accessibilityAddTraits(.isModal)
        // The windshield only reflects light on dark: the dark scheme's surface and ink, whatever the system.
        .environment(\.colorScheme, .dark)
        .accessibilityAction(.escape, exit)
        .onAppear(perform: brightness.raise)
        .onDisappear(perform: brightness.restore)
        .onChange(of: scenePhase, adjustBrightness)
    }

    /// Away from the app the person's brightness comes back; on return the HUD raises it again.
    private func adjustBrightness() {
        if scenePhase == .active {
            brightness.raise()
        } else {
            brightness.restore()
        }
    }
}

#Preview("Light") {
    HUDView(model: SpeedModel()) {}
        .environment(\.sbuAccent, .speed)
}

#Preview("Dark") {
    HUDView(model: SpeedModel()) {}
        .environment(\.sbuAccent, .speed)
        .preferredColorScheme(.dark)
}
