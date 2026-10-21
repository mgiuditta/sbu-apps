import SbuKit
import SwiftUI

/// The app inside `SbuTabShell`: Sonno, Statistiche, Home, Blocco, then Impostazioni (ADR-0017).
struct RootView: View {
    @State private var tab = AppTab.home

    var body: some View {
        SbuTabShell("Sbu Social", slug: "social", accent: .social, appIcon: Image(.appIconArtwork),
                    selection: $tab, settingsTab: AppTab.settings) {
            SbuTab("Sonno", systemImage: "moon.zzz", value: AppTab.sleep) {
                SleepView()
            }
            SbuTab("Statistiche", systemImage: "chart.bar", value: AppTab.stats) {
                StatsView()
            }
            SbuTab("Home", systemImage: "house", value: AppTab.home) {
                HomeView()
            }
            SbuTab("Blocco", systemImage: "shield", value: AppTab.block) {
                BlockView()
            }
        } settings: {
            EmptyView()
        }
    }
}

#Preview("Light") {
    RootView()
        .environment(AccountStore(defaults: UserDefaults(suiteName: "preview")!))
        .environment(WebViewPool())
}

#Preview("Dark") {
    RootView()
        .environment(AccountStore(defaults: UserDefaults(suiteName: "preview")!))
        .environment(WebViewPool())
        .preferredColorScheme(.dark)
}
