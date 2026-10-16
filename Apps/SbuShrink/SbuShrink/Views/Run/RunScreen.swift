import SbuKit
import SwiftUI

/// The run over the settings, as in the original: the compression, then Fatto in its place.
/// It closes only from its own buttons.
struct RunScreen: View {
    let model: ShrinkModel

    var body: some View {
        NavigationStack {
            ZStack {
                if model.stage == .done {
                    DoneView(model: model)
                        .transition(.opacity)
                } else {
                    CompressingView(model: model)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(SbuTheme.surface)
            .navigationTitle(model.stage == .done ? "Fatto" : "Compressione dei video")
            .navigationBarTitleDisplayMode(.inline)
        }
        .tint(SbuTheme.accentShrink)
        .interactiveDismissDisabled()
        .animation(.default, value: model.stage)
    }
}

#Preview("Light") {
    RunScreen(model: .preview(videos: 5))
}

#Preview("Dark") {
    RunScreen(model: .preview(videos: 5))
        .preferredColorScheme(.dark)
}
