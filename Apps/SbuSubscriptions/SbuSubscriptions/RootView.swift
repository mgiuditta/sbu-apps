import SbuKit
import SwiftUI

/// The app inside the standard Sbu shell.
struct RootView: View {
    @State private var currency = CurrencySettings()

    var body: some View {
        SbuAppShell("Sbu Subscriptions", slug: "subscriptions", accent: SbuTheme.accentSubscriptions, appIcon: Image(.appIconArtwork)) {
            MainView(currency: currency)
        } settings: {
            TotalSection()
            CurrencySection(settings: currency)
            OrganizeSection()
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
