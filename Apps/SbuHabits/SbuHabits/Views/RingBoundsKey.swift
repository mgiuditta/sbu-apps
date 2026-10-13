import SwiftUI

/// The bounds of a cell's ring, so a control can sit on it from outside the cell's single
/// VoiceOver element, as its own element.
struct RingBoundsKey: PreferenceKey {
    static let defaultValue: Anchor<CGRect>? = nil

    static func reduce(value: inout Anchor<CGRect>?, nextValue: () -> Anchor<CGRect>?) {
        value = value ?? nextValue()
    }
}
