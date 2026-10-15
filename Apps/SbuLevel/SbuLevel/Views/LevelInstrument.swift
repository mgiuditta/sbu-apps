import SbuKit
import SwiftUI

/// The drawing under the figure: the camera sight when it is on, otherwise the dial or bubble
/// with the bubble's axes underneath. A tap on it hides the bars and the pills, so nothing is
/// pressed by mistake while measuring, and shows them again; VoiceOver has the same as an action.
struct LevelInstrument: View {
    let model: LevelModel
    let camera: SightCamera
    let isFullScreen: Bool
    /// Blocca, for a volume button in the sight.
    let toggleLock: () -> Void
    let toggleFullScreen: () -> Void

    private var fullScreenAction: LocalizedStringKey {
        isFullScreen ? "Mostra i controlli" : "Schermo intero"
    }

    var body: some View {
        VStack(spacing: SbuTheme.space4) {
            Group {
                if model.isSighting {
                    SightView(
                        camera: camera,
                        rotation: model.reading.rotation,
                        volumeButtonAction: model.locksWithVolumeButton ? toggleLock : nil
                    )
                    .contentShape(.rect)
                    .onTapGesture(perform: toggleFullScreen)
                    .accessibilityAction(named: Text(fullScreenAction), toggleFullScreen)
                } else {
                    LevelIndicator(
                        reading: model.reading,
                        turnDial: model.turnDial,
                        fullScreenAction: fullScreenAction,
                        toggleFullScreen: toggleFullScreen
                    )
                }
            }
            .frame(maxWidth: 320)

            // Always laid out, so the dial does not jump when the iPhone lies down.
            if model.reading.mode == .flat {
                BubbleAxes(tiltX: model.reading.tiltX, tiltY: model.reading.tiltY, unit: model.unit)
                    .accessibilityAction(named: Text(fullScreenAction), toggleFullScreen)
            } else {
                // Its room only, out of sight and of VoiceOver.
                BubbleAxes(tiltX: 0, tiltY: 0, unit: model.unit)
                    .hidden()
            }
        }
    }
}

#Preview("Light") {
    LevelInstrument(model: LevelModel(source: FixedGravitySource.flat), camera: SightCamera(), isFullScreen: false, toggleLock: {}, toggleFullScreen: {})
        .padding(SbuTheme.space4)
        .background(SbuTheme.surface)
}

#Preview("Dark") {
    LevelInstrument(model: LevelModel(source: FixedGravitySource.screenshot), camera: SightCamera(), isFullScreen: true, toggleLock: {}, toggleFullScreen: {})
        .padding(SbuTheme.space4)
        .background(SbuTheme.surface)
        .preferredColorScheme(.dark)
}
