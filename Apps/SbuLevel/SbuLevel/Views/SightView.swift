import SbuKit
import SwiftUI
import UIKit

/// The camera sight: the rear camera's picture inside the dial's ring, with crosshair and horizon.
/// Without the picture the dial stays paper; a refused camera offers the way to Settings.
struct SightView: View {
    @Environment(\.openURL) private var openURL

    let camera: SightCamera
    /// Calibrated device roll in degrees, for the horizon.
    let rotation: Double
    /// What a volume button does while the camera runs; `nil` leaves the buttons to the volume.
    var volumeButtonAction: (() -> Void)?

    var body: some View {
        ZStack {
            Circle()
                .fill(SbuTheme.surfaceSunken)

            if camera.access == .allowed {
                CameraPreview(session: camera.session)
                    .clipShape(.circle)
                    .accessibilityHidden(true)
            }

            if camera.isRunning, let volumeButtonAction {
                VolumeButtonTrigger(action: volumeButtonAction)
                    .frame(width: 0, height: 0)
                    .accessibilityHidden(true)
            }

            SightReticle(rotation: rotation)

            DialScale(showsValues: false)

            if camera.access == .denied {
                Button("Consenti la fotocamera", action: openSettings)
                    .buttonStyle(SbuFieldPillStyle())
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("Mirino"))
        .accessibilityActions {
            if camera.access == .denied {
                Button("Consenti la fotocamera", action: openSettings)
            }
        }
    }

    private func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            openURL(url)
        }
    }
}

#Preview("Light") {
    SightView(camera: SightCamera(), rotation: 6)
        .padding(SbuTheme.space4)
        .background(SbuTheme.surface)
}

#Preview("Dark") {
    SightView(camera: SightCamera(), rotation: -10)
        .padding(SbuTheme.space4)
        .background(SbuTheme.surface)
        .preferredColorScheme(.dark)
}
