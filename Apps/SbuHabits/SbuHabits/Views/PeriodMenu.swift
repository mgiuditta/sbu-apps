import SbuKit
import SwiftUI

/// The filled capsule at the top of the Statistiche, as in Streaks: the period on show, and a
/// native menu to choose another.
struct PeriodMenu: View {
    @Binding var period: StatisticsPeriod

    var body: some View {
        Menu {
            Picker("Periodo", selection: $period) {
                ForEach(StatisticsPeriod.allCases) { period in
                    Text(period.title)
                        .tag(period)
                }
            }
        } label: {
            Text(period.title)
                .font(SbuTheme.headline)
                .textCase(.uppercase)
                .multilineTextAlignment(.center)
                .foregroundStyle(SbuTheme.onAccent)
                .padding(.horizontal, SbuTheme.space6)
                .padding(.vertical, SbuTheme.space3)
                .frame(maxWidth: .infinity, minHeight: SbuTheme.controlRoundSm)
                .background(.tint, in: .capsule)
                .contentShape(.capsule)
        }
        .accessibilityLabel(Text("Periodo"))
        .accessibilityValue(Text(period.title))
    }
}

#Preview("Light") {
    PeriodMenu(period: .constant(.all))
        .padding(SbuTheme.space4)
        .background(SbuTheme.paper)
        .tint(SbuTheme.ink)
}

#Preview("Dark") {
    PeriodMenu(period: .constant(.month))
        .padding(SbuTheme.space4)
        .background(SbuTheme.paper)
        .tint(SbuTheme.ink)
        .preferredColorScheme(.dark)
}
