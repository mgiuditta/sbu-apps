import SbuKit
import SwiftUI

/// The drawing under the figure: the camera sight when it is on, otherwise the dial or bubble
/// with the bubble's axes underneath.
struct LevelInstrument: View {
    let model: LevelModel
    let camera: SightCamera
    /// Blocca, for a volume button in the sight.
    let toggleLock: () -> Void

    var body: some View {
        VStack(spacing: SbuTheme.space4) {
            Group {
                if model.isSighting {
                    SightView(
                        camera: camera,
                        rotation: model.reading.rotation,
                        volumeButtonAction: model.locksWithVolumeButton ? toggleLock : nil
                    )
                } else {
                    LevelIndicator(reading: model.reading, turnDial: model.turnDial)
                }
            }
            .frame(maxWidth: 320)

            // Always laid out, so the dial does not jump when the iPhone lies down.
            BubbleAxes(tiltX: model.reading.tiltX, tiltY: model.reading.tiltY, unit: model.unit)
                .opacity(model.reading.mode == .flat ? 1 : 0)
                .accessibilityHidden(model.reading.mode != .flat)
        }
    }
}

#Preview("Light") {
    LevelInstrument(model: LevelModel(source: FixedGravitySource.flat), camera: SightCamera(), toggleLock: {})
        .padding(SbuTheme.space4)
        .background(SbuTheme.surface)
}

#Preview("Dark") {
    LevelInstrument(model: LevelModel(source: FixedGravitySource.screenshot), camera: SightCamera(), toggleLock: {})
        .padding(SbuTheme.space4)
        .background(SbuTheme.surface)
        .preferredColorScheme(.dark)
}
