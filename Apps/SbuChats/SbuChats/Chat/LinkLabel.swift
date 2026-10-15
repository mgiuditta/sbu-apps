import SbuKit
import SwiftUI

/// A row that leads to another screen: a muted symbol and its name.
struct LinkLabel: View {
    let title: LocalizedStringKey
    let systemImage: String

    var body: some View {
        Label {
            Text(title)
                .font(SbuTheme.body)
                .foregroundStyle(SbuTheme.ink)
        } icon: {
            // Not the accent: on this screen it belongs to the figure's full stop.
            Image(systemName: systemImage)
                .fontWeight(.medium)
                .foregroundStyle(SbuTheme.inkMuted)
        }
    }
}

#Preview("Light") {
    List { LinkLabel(title: "Attività", systemImage: "chart.bar") }
}

#Preview("Dark") {
    List { LinkLabel(title: "Attività", systemImage: "chart.bar") }
        .preferredColorScheme(.dark)
}
