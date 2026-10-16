import SbuKit
import SwiftUI

/// A chore in a list, as in Tody: its name, its dirt bar, when it is due and its effort.
struct ChoreRow: View {
    let name: String
    let effort: Effort
    let state: ChoreState

    var body: some View {
        VStack(alignment: .leading, spacing: SbuTheme.space2) {
            Text(name)
                .font(SbuTheme.headline)
                .foregroundStyle(SbuTheme.ink)
            ProgressView(value: state.level)
                .tint(state.status == .paused ? SbuTheme.inkMuted : nil)
                .accessibilityHidden(true)
            HStack(alignment: .firstTextBaseline, spacing: SbuTheme.space2) {
                DueText(label: DueLabel(state))
                    .font(SbuTheme.subheadline)
                Spacer(minLength: 0)
                EffortDots(effort: effort)
            }
        }
        .padding(.vertical, SbuTheme.space1)
        .accessibilityElement(children: .combine)
    }
}

#Preview("Light") {
    ChoreRowPreview()
}

#Preview("Dark") {
    ChoreRowPreview()
        .preferredColorScheme(.dark)
}

private struct ChoreRowPreview: View {
    private let now = Date.now

    var body: some View {
        List {
            row("Pulire il WC", every: 7, daysAgo: 13, effort: .medium)
            row("Lavare i piatti", every: 1, daysAgo: 1, effort: .light)
            row("Pulire il forno", every: 30, daysAgo: 12, effort: .heavy)
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(SbuTheme.surface)
        .tint(SbuTheme.accentTidy)
    }

    private func row(_ name: String, every days: Int, daysAgo: Double, effort: Effort) -> some View {
        let clock = ChoreClock(lastDone: now.addingTimeInterval(-daysAgo * 86_400))
        return ChoreRow(name: name, effort: effort, state: ChoreState(frequency: Frequency(days, .day), clock: clock, now: now, calendar: .current))
            .listRowBackground(SbuTheme.surfaceRaised)
    }
}
