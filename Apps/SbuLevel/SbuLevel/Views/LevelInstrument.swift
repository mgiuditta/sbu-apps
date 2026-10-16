import SbuKit
import SwiftUI

/// The instrument of Mirino: the camera sight above the figure. A tap on it hides the bars and the
/// pills, so nothing is pressed by mistake while aiming, and shows them again; VoiceOver has the
/// same as an action. On a level or an edge there is no drawing: the figure and its full stop say it all.
struct LevelInstrument: View {
    let model: LevelModel
    let camera: SightCamera
    /// The full-screen action VoiceOver offers, and its name.
    let fullScreenAction: LocalizedStringKey
    /// Blocca, for a volume button in the sight.
    let toggleLock: () -> Void
    let toggleFullScreen: () -> Void

    var body: some View {
        SightView(
            camera: camera,
            rotation: model.reading.rotation,
            volumeButtonAction: model.locksWithVolumeButton ? toggleLock : nil
        )
        // Thirteen cells: a sight as wide as the old dial, on the grid.
        .frame(maxWidth: SbuTheme.gridCell * 13)
        .frame(maxWidth: .infinity)
        .contentShape(.rect)
        .onTapGesture(perform: toggleFullScreen)
        .accessibilityAction(named: Text(fullScreenAction), toggleFullScreen)
    }
}

#Preview("Light") {
    LevelInstrument(model: LevelModel(source: FixedGravitySource.screenshot), camera: SightCamera(), fullScreenAction: "Schermo intero", toggleLock: {}, toggleFullScreen: {})
        .padding(SbuTheme.space4)
        .background(SbuTheme.paper)
}

#Preview("Dark") {
    LevelInstrument(model: LevelModel(source: FixedGravitySource.screenshot), camera: SightCamera(), fullScreenAction: "Mostra i controlli", toggleLock: {}, toggleFullScreen: {})
        .padding(SbuTheme.space4)
        .background(SbuTheme.paper)
        .preferredColorScheme(.dark)
}
