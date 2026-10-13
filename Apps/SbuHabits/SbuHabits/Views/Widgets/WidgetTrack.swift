import SbuKit
import SwiftUI
import WidgetKit

/// The style of what is still empty: a ring's track, a day not done, a week day without
/// completions, the area under the line. On paper it is `line`; on a tinted or clear Home Screen
/// every opaque color turns into the same tint, so it becomes faint by its alpha instead, or an
/// empty ring would read as a full one.
enum WidgetTrack {
    static func style(for renderingMode: WidgetRenderingMode) -> AnyShapeStyle {
        renderingMode == .fullColor ? AnyShapeStyle(SbuTheme.line) : AnyShapeStyle(.quaternary)
    }
}
