import UIKit

/// Turns the screen to full brightness for the HUD, and gives back the person's level afterwards.
final class ScreenBrightness {
    private var saved: CGFloat?

    private var screen: UIScreen? {
        UIApplication.shared.connectedScenes.lazy.compactMap { $0 as? UIWindowScene }.first?.screen
    }

    /// Full brightness, remembering the level to give back. Calling it twice keeps the first level.
    func raise() {
        guard let screen else { return }
        if saved == nil {
            saved = screen.brightness
        }
        screen.brightness = 1
    }

    /// Gives back the level `raise()` found, if it raised it.
    func restore() {
        guard let saved, let screen else { return }
        screen.brightness = saved
        self.saved = nil
    }
}
