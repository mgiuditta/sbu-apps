import SwiftUI

/// The tool screen: the minutes spent in Sbu Social today and the Platforms.
struct HomeView: View {
    var body: some View {
        TabScreen(title: "Home", sentence: "Apri un social: qui conti i minuti di oggi.")
    }
}

#Preview("Light") {
    HomeView()
}

#Preview("Dark") {
    HomeView()
        .preferredColorScheme(.dark)
}
