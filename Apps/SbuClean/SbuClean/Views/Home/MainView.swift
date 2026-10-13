import SbuKit
import SwiftUI

/// The tool screen: the space you can free once the library is open, the permission first.
struct MainView: View {
    let model: CleanModel

    var body: some View {
        Group {
            if model.access.canRead {
                HomeScreen(model: model)
            } else {
                AccessScreen(model: model)
            }
        }
        .task(id: model.access) {
            await model.start()
        }
    }
}

#Preview("Light") {
    NavigationStack {
        MainView(model: .preview)
    }
    .tint(SbuTheme.accentClean)
}

#Preview("Dark") {
    NavigationStack {
        MainView(model: .preview)
    }
    .tint(SbuTheme.accentClean)
    .preferredColorScheme(.dark)
}
