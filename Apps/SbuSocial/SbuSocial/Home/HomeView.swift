import SbuKit
import SwiftUI

/// The tool screen: the Platforms, one square each; a tap opens it in the filtered browser.
struct HomeView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: SbuTheme.space6) {
                SbuScreenTitle("Home", cartiglio: Cartiglio.today)
                PlatformGrid()
            }
            .padding(SbuTheme.space4)
            .frame(maxWidth: .infinity, alignment: .topLeading)
        }
        .sbuPaper(grid: true)
        .navigationDestination(for: Platform.self) { platform in
            PlatformScreen(platform: platform)
        }
    }
}

#Preview("Light") {
    NavigationStack {
        HomeView()
    }
}

#Preview("Dark") {
    NavigationStack {
        HomeView()
    }
    .preferredColorScheme(.dark)
}
