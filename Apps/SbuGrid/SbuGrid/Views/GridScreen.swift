import SbuKit
import SwiftUI

/// The photo with the grid, under its one figure: the side of a cell when there is a sheet,
/// columns × rows when there is none.
struct GridScreen: View {
    let model: GridModel
    let picture: CGImage
    let actions: GridActions

    private var figure: GridFigure {
        GridFigure(paper: model.paper, settings: model.settings, count: model.count)
    }

    /// Already localized: the key finds no other translation and shows as it is.
    private var context: LocalizedStringKey? {
        figure.context.map { LocalizedStringKey($0) }
    }

    var body: some View {
        switch figure.kind {
        case let .cell(length, unit):
            SbuToolField(
                "Cella",
                value: length,
                format: .number.precision(.fractionLength(0...2)),
                unit: LengthFormat.symbol(unit),
                spokenValue: Text(verbatim: figure.spoken),
                context: context
            ) {
                photo
            } pills: {
                GridPills(actions: actions)
            }
        case let .count(count):
            SbuToolField(
                "Griglia",
                value: count,
                format: .gridCount,
                spokenValue: Text(verbatim: figure.spoken),
                context: context
            ) {
                photo
            } pills: {
                GridPills(actions: actions)
            }
        }
    }

    private var photo: some View {
        ZoomablePicture(aspect: model.pictureSize, label: "Foto con la griglia", value: model.count.spoken) {
            GridPicture(image: picture, settings: model.settings, rule: model.cellRule)
        }
        // A new photo or a new crop starts unzoomed.
        .id(model.pictureID)
        // The photo takes all the height the figure and the pills leave.
        .layoutPriority(1)
    }
}

#Preview("Light") {
    NavigationStack {
        GridScreen(model: .forLaunch(.demo), picture: DemoPhoto.stillLife(), actions: .preview)
    }
    .tint(SbuTheme.accentGrid)
}

#Preview("Dark") {
    NavigationStack {
        GridScreen(model: .forLaunch(.demo), picture: DemoPhoto.stillLife(), actions: .preview)
    }
    .tint(SbuTheme.accentGrid)
    .preferredColorScheme(.dark)
}
