import SbuKit
import SwiftUI
import UIKit

/// The app inside the standard Sbu shell. The screen stays on while videos compress: the encoder
/// stops when the iPhone locks.
struct RootView: View {
    @State private var model: ShrinkModel

    init(model: ShrinkModel = LaunchMode.makeModel()) {
        _model = State(initialValue: model)
    }

    var body: some View {
        SbuAppShell("Sbu Shrink", slug: "shrink", accent: SbuTheme.accentShrink, appIcon: Image(.appIconArtwork)) {
            MainView(model: model)
        } settings: {
            EmptyView()
        }
        .onChange(of: model.stage) { _, stage in
            UIApplication.shared.isIdleTimerDisabled = stage == .compressing
        }
    }
}

#Preview("Light") {
    RootView(model: .preview())
}

#Preview("Dark") {
    RootView(model: .preview())
        .preferredColorScheme(.dark)
}
