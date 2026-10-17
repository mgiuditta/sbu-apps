import SbuKit
import SwiftUI

/// The bar at the bottom of the tool screen: the settings gear at the leading edge, Statistiche
/// at the trailing edge. Both in `ink` on raised paper: on this screen the only color is the
/// figure's full stop.
struct HomeBar: View {
    @Environment(\.showSettings) private var showSettings

    let isStatisticsEnabled: Bool
    let showStatistics: () -> Void

    var body: some View {
        HStack(spacing: SbuTheme.space2) {
            // The shell's own gear is hidden in Sbu Habits: this one opens the same sheet.
            Button("Impostazioni", systemImage: "gearshape", action: openSettings)

            Spacer(minLength: 0)

            Button("Statistiche", systemImage: "chart.bar", action: showStatistics)
                .disabled(isStatisticsEnabled == false)
        }
        .labelStyle(.iconOnly)
        .buttonStyle(RoundButtonStyle(side: SbuTheme.controlRound))
    }

    private func openSettings() {
        showSettings()
    }
}

#Preview("Light") {
    HomeBar(isStatisticsEnabled: true) {}
        .padding(SbuTheme.space4)
        .background(SbuTheme.paper)
        .tint(SbuTheme.ink)
}

#Preview("Dark") {
    HomeBar(isStatisticsEnabled: true) {}
        .padding(SbuTheme.space4)
        .background(SbuTheme.paper)
        .tint(SbuTheme.ink)
        .preferredColorScheme(.dark)
}
