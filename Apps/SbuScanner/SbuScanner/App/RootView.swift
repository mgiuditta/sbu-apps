import SbuKit
import SwiftUI

/// The app inside the standard Sbu shell.
struct RootView: View {
    var body: some View {
        SbuAppShell("Sbu Scanner", slug: "scanner", accent: SbuTheme.accentScanner, appIcon: Image(.appIconArtwork)) {
            ScannerScreen()
        } settings: {
            ScannerSettingsSection()
        }
    }
}

#Preview("Light") {
    RootView()
        .modelContainer(.preview)
}

#Preview("Dark") {
    RootView()
        .modelContainer(.preview)
        .preferredColorScheme(.dark)
}
