import AVKit
import SbuKit
import SwiftUI

/// The system picker for the audio output: speaker, headphones, AirPlay.
struct RoutePicker: UIViewRepresentable {
    func makeUIView(context: Context) -> AVRoutePickerView {
        let view = AVRoutePickerView()
        view.tintColor = UIColor(SbuTheme.inkMuted)
        view.activeTintColor = UIColor(SbuTheme.ink)
        view.accessibilityLabel = String(localized: "Uscita audio")
        return view
    }

    func updateUIView(_ view: AVRoutePickerView, context: Context) {}
}
