import SbuKit
import SwiftUI

/// The photo with the grid over it, at the photo's shape: what the screen shows, the export
/// saves and the PDF prints.
struct GridPicture: View {
    let image: CGImage
    let settings: GridSettings
    let rule: CellRule

    var body: some View {
        Image(decorative: image, scale: 1)
            .resizable()
            .interpolation(.high)
            // Black and white keeps the values and drops the hues, to read light and shade.
            .grayscale(settings.isBlackAndWhite ? 1 : 0)
            .overlay {
                GridOverlay(rule: rule, settings: settings)
            }
            .aspectRatio(CGSize(width: image.width, height: image.height), contentMode: .fit)
    }
}

#Preview("Light") {
    GridPicture(image: DemoPhoto.stillLife(), settings: GridSettings(), rule: GridSettings().cellRule)
        .padding(SbuTheme.space4)
        .background(SbuTheme.surface)
}

#Preview("Dark") {
    GridPicture(image: DemoPhoto.stillLife(), settings: GridSettings(), rule: GridSettings().cellRule)
        .padding(SbuTheme.space4)
        .background(SbuTheme.surface)
        .preferredColorScheme(.dark)
}
