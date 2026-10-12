import SwiftUI

/// The Sbu design tokens as typed values.
///
/// Token names match `Design/tokens.json`, camel-cased: `surface-raised` is `surfaceRaised`,
/// `space-4` is `space4`. Colors, spacing, radii, strokes and the full stop metrics are generated
/// by `Tools/sync_tokens.py`; typography lives in `SbuTheme+Typography.swift`.
///
/// Text and glyphs on any `accent*` take `onAccent`, which adapts to the color scheme: white in
/// light, warm black in dark.
public enum SbuTheme {
    /// The bundle holding SbuKit's assets, fonts and strings.
    static let bundle = Bundle.module
}
