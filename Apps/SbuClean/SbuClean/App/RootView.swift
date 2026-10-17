import SbuKit
import SwiftUI

/// The app inside the standard Sbu shell.
struct RootView: View {
    let model: CleanModel

    var body: some View {
        SbuAppShell("Sbu Clean", slug: "clean", accent: .clean, appIcon: Image(.appIconArtwork)) {
            MainView(model: model)
        } settings: {
            LibrarySettingsSection(model: model)
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
