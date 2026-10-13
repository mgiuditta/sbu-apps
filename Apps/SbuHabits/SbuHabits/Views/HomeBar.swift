import SbuKit
import SwiftUI

/// The bar at the bottom of the tool screen, as in Streaks: the settings gear at the leading
/// edge, the page dots in the middle, Statistiche at the trailing edge. Both buttons in `ink` on
/// raised paper: on this screen the accent belongs to the figure's full stop.
struct HomeBar: View {
    @Environment(\.showSettings) private var showSettings

    let pageCount: Int
    @Binding var page: Int?
    let isStatisticsEnabled: Bool
    let showStatistics: () -> Void

    var body: some View {
        HStack(spacing: SbuTheme.space2) {
            // The shell's own gear is hidden in Sbu Habits: this one opens the same sheet.
            Button("Impostazioni", systemImage: "gearshape", action: openSettings)

            Spacer(minLength: 0)

            PageDots(count: pageCount, page: $page)

            Spacer(minLength: 0)

            Button("Statistiche", systemImage: "star.fill", action: showStatistics)
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
    HomeBar(pageCount: 2, page: .constant(0), isStatisticsEnabled: true) {}
        .padding(SbuTheme.space4)
        .background(SbuTheme.surface)
        .tint(SbuTheme.accentHabits)
}

#Preview("Dark") {
    HomeBar(pageCount: 2, page: .constant(0), isStatisticsEnabled: true) {}
        .padding(SbuTheme.space4)
        .background(SbuTheme.surface)
        .tint(SbuTheme.accentHabits)
        .preferredColorScheme(.dark)
}
