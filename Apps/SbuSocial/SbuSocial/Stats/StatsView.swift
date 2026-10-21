import SwiftUI

/// The minutes of the last 7 days.
struct StatsView: View {
    var body: some View {
        TabScreen(title: "Statistiche", sentence: "Qui vedi i tuoi minuti degli ultimi 7 giorni.")
    }
}

#Preview("Light") {
    StatsView()
}

#Preview("Dark") {
    StatsView()
        .preferredColorScheme(.dark)
}
