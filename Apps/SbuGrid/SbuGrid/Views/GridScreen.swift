import SbuKit
import SwiftUI

/// The tool screen: Griglia and its cartiglio, the one figure on the grid (the side of a cell
/// when there is a sheet, columns × rows when there is none), then the photo with its grid and
/// the tools under it.
///
/// The notebook grid stays in the figure zone: the photo is the person's, and its own grid is the
/// instrument, so it sits on plain paper.
struct GridScreen: View {
    let model: GridModel
    let picture: CGImage
    let actions: GridActions
    /// Set once the gridded photo is saved to Photos: the figure gives way to "Salvata".
    @Binding var isClosing: Bool

    /// The heights of the figure zone and of the pills, measured: the photo takes what they leave.
    @State private var zoneHeight: CGFloat = 0
    @State private var pillsHeight: CGFloat = 0

    private var figure: GridFigure {
        GridFigure(paper: model.paper, settings: model.settings, count: model.count)
    }

    var body: some View {
        GeometryReader { proxy in
            // In a scroll view, as on the other tool screens: outside one, the accessibility audit
            // never finishes with SbuFigure. At the usual sizes everything fits and nothing
            // scrolls; at the largest ones the photo keeps a useful size and the screen scrolls.
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    figureZone
                        .onGeometryChange(for: CGFloat.self) { proxy in
                            proxy.size.height
                        } action: { height in
                            zoneHeight = height
                        }

                    VStack(spacing: SbuTheme.space6) {
                        photo
                            .frame(height: photoHeight(in: proxy.size))

                        GridPills(actions: actions)
                            .onGeometryChange(for: CGFloat.self) { proxy in
                                proxy.size.height
                            } action: { height in
                                pillsHeight = height
                            }
                    }
                    .padding(.horizontal, SbuTheme.space4)
                    .padding(.bottom, SbuTheme.space8)
                }
            }
            .scrollBounceBehavior(.basedOnSize)
        }
        .sbuPaper(grid: false)
    }

    private var figureZone: some View {
        VStack(alignment: .leading, spacing: SbuTheme.space6) {
            SbuScreenTitle("Griglia", cartiglio: figure.cartiglio)

            SbuFigure(
                value: figure.value,
                context: figure.context.map { Text(verbatim: $0) },
                accessibilityLabel: Text(verbatim: figure.accessibilityLabel)
            )
            .sbuClosure($isClosing, word: "Salvata")
        }
        .padding(.horizontal, SbuTheme.space4)
        .padding(.top, SbuTheme.space4)
        .padding(.bottom, SbuTheme.space6)
        .frame(maxWidth: .infinity, alignment: .leading)
        .sbuPaper(grid: true)
    }

    private var photo: some View {
        ZoomablePicture(aspect: model.pictureSize, label: "Foto con la griglia", value: model.count.spoken) {
            GridPicture(image: picture, settings: model.settings, rule: model.cellRule)
        }
        // A new photo or a new crop starts unzoomed.
        .id(model.pictureID)
    }

    /// The height left under the figure and over the pills; when that is under half the photo at
    /// full width, as at the largest text sizes, the photo at full width and the screen scrolls.
    private func photoHeight(in size: CGSize) -> CGFloat {
        let left = size.height - zoneHeight - pillsHeight - SbuTheme.space6 - SbuTheme.space8
        let width = size.width - SbuTheme.space4 * 2
        let fullWidth = AspectFit.size(of: model.pictureSize, in: CGSize(width: width, height: .greatestFiniteMagnitude)).height
        return left < fullWidth / 2 ? fullWidth : left
    }
}

#Preview("Light") {
    @Previewable @State var isClosing = false
    NavigationStack {
        GridScreen(model: .forLaunch(.demo), picture: DemoPhoto.stillLife(), actions: .preview, isClosing: $isClosing)
    }
    .environment(\.sbuAccent, .grid)
}

#Preview("Dark") {
    @Previewable @State var isClosing = false
    NavigationStack {
        GridScreen(model: .forLaunch(.demo), picture: DemoPhoto.stillLife(), actions: .preview, isClosing: $isClosing)
    }
    .environment(\.sbuAccent, .grid)
    .preferredColorScheme(.dark)
}

#Preview("AX5") {
    @Previewable @State var isClosing = false
    NavigationStack {
        GridScreen(model: .forLaunch(.demo), picture: DemoPhoto.stillLife(), actions: .preview, isClosing: $isClosing)
    }
    .environment(\.sbuAccent, .grid)
    .dynamicTypeSize(.accessibility5)
}

#Preview("Salvata") {
    @Previewable @State var isClosing = true
    NavigationStack {
        GridScreen(model: .forLaunch(.demo), picture: DemoPhoto.stillLife(), actions: .preview, isClosing: $isClosing)
    }
    .environment(\.sbuAccent, .grid)
}
