import MediaPlayer
import SbuKit
import SwiftUI

/// The device volume, as in the original: the only public way to change it is `MPVolumeView`.
/// The simulator draws nothing here.
struct SystemVolumeSlider: UIViewRepresentable {
    func makeUIView(context: Context) -> MPVolumeView {
        let view = MPVolumeView()
        view.tintColor = UIColor(SbuTheme.ink)
        return view
    }

    func updateUIView(_ view: MPVolumeView, context: Context) {}
}
