import SbuKit
import SwiftUI

/// Only the photo and the grid, edge to edge, to zoom into a cell; a button closes it.
struct FullScreenView: View {
    @Environment(\.dismiss) private var dismiss

    let model: GridModel

    var body: some View {
        ZStack(alignment: .topTrailing) {
            if let picture = model.picture {
                ZoomablePicture(aspect: model.pictureSize, label: "Foto con la griglia", value: model.count.spoken) {
                    GridPicture(image: picture, settings: model.settings, rule: model.cellRule)
                }
                .ignoresSafeArea()
            }

            Button("Chiudi", systemImage: "xmark", action: close)
                .labelStyle(.iconOnly)
                .buttonStyle(SbuFieldPillStyle())
                .padding(SbuTheme.space4)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(SbuTheme.paper)
        .statusBarHidden()
        .persistentSystemOverlays(.hidden)
    }

    private func close() {
        dismiss()
    }
}

#Preview("Light") {
    FullScreenView(model: .forLaunch(.demo))
        .tint(SbuTheme.ink)
}

#Preview("Dark") {
    FullScreenView(model: .forLaunch(.demo))
        .tint(SbuTheme.ink)
        .preferredColorScheme(.dark)
}
