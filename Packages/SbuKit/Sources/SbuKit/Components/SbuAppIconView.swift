import SwiftUI

/// Shows an app icon inside the app, in onboarding or settings, clipped like the home screen.
///
/// The real icon ships as a 1024 PNG in `AppIcon.appiconset`; this view draws the same SVG,
/// which apps add to their asset catalog as `AppIconArtwork`. The icon is decorative.
public struct SbuAppIconView: View {
    private let image: Image
    private let side: CGFloat

    /// Creates an icon view.
    /// - Parameters:
    ///   - image: The icon artwork, already square.
    ///   - side: Edge length in points; the design system uses 64–88 in onboarding and settings.
    public init(image: Image, side: CGFloat = 64) {
        self.image = image
        self.side = side
    }

    public var body: some View {
        image
            .resizable()
            .scaledToFit()
            .frame(width: side, height: side)
            .clipShape(.rect(cornerRadius: side * SbuTheme.radiusIcon, style: .continuous))
            .accessibilityHidden(true)
    }
}

#Preview("Light") {
    SbuAppIconViewPreview()
}

#Preview("Dark") {
    SbuAppIconViewPreview()
        .preferredColorScheme(.dark)
}

private struct SbuAppIconViewPreview: View {
    var body: some View {
        HStack(spacing: SbuTheme.space5) {
            SbuAppIconView(image: Image(decorative: "sbu-mark", bundle: SbuTheme.bundle), side: 88)
            SbuAppIconView(image: Image(decorative: "sbu-mark", bundle: SbuTheme.bundle))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(SbuTheme.surface)
    }
}
