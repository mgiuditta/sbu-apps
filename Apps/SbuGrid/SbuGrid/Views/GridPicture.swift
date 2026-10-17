import SbuKit
import SwiftUI

/// The photo with the grid over it, at the photo's shape: what the screen shows, the export
/// saves and the PDF prints.
struct GridPicture: View {
    let image: CGImage
    let settings: GridSettings
    let rule: CellRule
    /// Below 1 the photo lets the camera show through while tracing; the grid stays as set.
    var photoOpacity = 1.0

    var body: some View {
        Image(decorative: image, scale: 1)
            .resizable()
            .interpolation(.high)
            // Black and white keeps the values and drops the hues, to read light and shade.
            .grayscale(settings.isBlackAndWhite ? 1 : 0)
            .opacity(photoOpacity)
            .overlay {
                GridOverlay(rule: rule, settings: settings)
            }
            .aspectRatio(CGSize(width: image.width, height: image.height), contentMode: .fit)
    }
}

#Preview("Light") {
    GridPicture(image: DemoPhoto.stillLife(), settings: GridSettings(), rule: GridSettings().cellRule)
        .padding(SbuTheme.space4)
        .background(SbuTheme.paper)
}

#Preview("Dark") {
    GridPicture(image: DemoPhoto.stillLife(), settings: GridSettings(), rule: GridSettings().cellRule)
        .padding(SbuTheme.space4)
        .background(SbuTheme.paper)
        .preferredColorScheme(.dark)
}
