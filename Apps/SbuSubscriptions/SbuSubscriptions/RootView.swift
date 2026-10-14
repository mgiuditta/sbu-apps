import SbuKit
import SwiftUI

/// The app inside the standard Sbu shell.
struct RootView: View {
    @State private var currency = CurrencySettings()

    var body: some View {
        SbuAppShell("Sbu Subscriptions", slug: "subscriptions", accent: SbuTheme.accentSubscriptions, appIcon: Image(.appIconArtwork)) {
            MainView()
        } settings: {
            CurrencySection(settings: currency)
        }
    }
}

#Preview("Light") {
    RootView()
        .modelContainer(try! .subscriptions(inMemory: true))
}

#Preview("Dark") {
    RootView()
        .modelContainer(try! .subscriptions(inMemory: true))
        .preferredColorScheme(.dark)
}
