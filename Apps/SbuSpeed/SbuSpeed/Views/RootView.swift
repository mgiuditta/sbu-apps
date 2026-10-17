import SbuKit
import SwiftUI

/// The app inside the standard Sbu shell.
struct RootView: View {
    @State private var model = SpeedModel()

    var body: some View {
        SbuAppShell("Sbu Speed", slug: "speed", accent: .speed, appIcon: Image(.appIconArtwork)) {
            MainView(model: model)
        } settings: {
            UnitSection(model: model)
            SpeedLimitSection(model: model)
        }
    }
}

#Preview("Light") {
    RootView()
}

#Preview("Dark") {
    RootView()
        .preferredColorScheme(.dark)
}
