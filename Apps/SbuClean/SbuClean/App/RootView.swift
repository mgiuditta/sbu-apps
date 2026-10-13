import SbuKit
import SwiftUI

/// The app inside the standard Sbu shell.
struct RootView: View {
    let model: CleanModel

    var body: some View {
        SbuAppShell("Sbu Clean", slug: "clean", accent: SbuTheme.accentClean, appIcon: Image(.appIconArtwork)) {
            MainView(model: model)
        } settings: {
            EmptyView()
        }
        .environment(\.photoLibrary, model.library)
    }
}

#Preview("Light") {
    RootView(model: .preview)
}

#Preview("Dark") {
    RootView(model: .preview)
        .preferredColorScheme(.dark)
}
