import AVKit
import SwiftUI
import UIKit

/// Calls `action` when a volume button, or the Camera Control, is pressed. iOS hands those presses
/// to an app only while its camera runs, through `AVCaptureEventInteraction` (iOS 17.2): so this
/// works in the sight, without touching the audio. Invisible.
struct VolumeButtonTrigger: UIViewRepresentable {
    static var isSupported: Bool {
        if #available(iOS 17.2, *) { true } else { false }
    }

    let action: () -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(action: action)
    }

    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.isUserInteractionEnabled = false
        view.isAccessibilityElement = false
        if #available(iOS 17.2, *) {
            let coordinator = context.coordinator
            view.addInteraction(AVCaptureEventInteraction { event in
                // One press, one toggle: act when the button comes back up.
                if event.phase == .ended {
                    coordinator.action()
                }
            })
        }
        return view
    }

    func updateUIView(_ view: UIView, context: Context) {
        context.coordinator.action = action
    }

    final class Coordinator {
        var action: () -> Void

        init(action: @escaping () -> Void) {
            self.action = action
        }
    }
}
