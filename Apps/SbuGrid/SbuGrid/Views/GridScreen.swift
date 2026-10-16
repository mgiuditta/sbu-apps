import SbuKit
import SwiftUI

/// The photo with the grid, under its one figure: how many columns and rows it has.
struct GridScreen: View {
    let model: GridModel
    let photo: CGImage
    let showGrid: () -> Void
    let showFullScreen: () -> Void

    private var context: LocalizedStringKey? {
        model.settings.hasSquareCells ? "Celle quadrate" : nil
    }

    var body: some View {
        SbuToolField(
            "Griglia",
            value: model.count,
            format: .gridCount,
            spokenValue: Text(verbatim: model.count.spoken),
            context: context
        ) {
            ZoomablePicture(aspect: model.pictureSize, label: "Foto con la griglia", value: model.count.spoken) {
                GridPicture(image: photo, settings: model.settings, rule: model.cellRule)
            }
            .id(model.photoID)
            // The photo takes all the height the figure and the pills leave.
            .layoutPriority(1)
        } pills: {
            GridPills(showGrid: showGrid, showFullScreen: showFullScreen)
        }
    }
}

#Preview("Light") {
    NavigationStack {
        GridScreen(model: .forLaunch(.demo), photo: DemoPhoto.stillLife(), showGrid: {}, showFullScreen: {})
    }
    .tint(SbuTheme.accentGrid)
}

#Preview("Dark") {
    NavigationStack {
        GridScreen(model: .forLaunch(.demo), photo: DemoPhoto.stillLife(), showGrid: {}, showFullScreen: {})
    }
    .tint(SbuTheme.accentGrid)
    .preferredColorScheme(.dark)
}
