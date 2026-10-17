import SbuKit
import SwiftUI

/// A chore in the to-do list: its box, ticked once done today, its name and, in mono, when it is
/// due and how much work it is; the chevron opens its screen.
struct TodayChoreRow: View {
    let item: TodayList.Item
    let chore: Chore
    let setDone: (Chore, Bool) -> Void

    var body: some View {
        HStack(spacing: SbuTheme.space3) {
            Toggle(isOn: isDone) {
                VStack(alignment: .leading, spacing: SbuTheme.space1) {
                    Text(item.chore.name)
                        .font(SbuTheme.body)
                        .fontWeight(.medium)
                        .foregroundStyle(item.isDone ? SbuTheme.inkMuted : SbuTheme.ink)
                    metadata
                }
            }
            .toggleStyle(SbuCheckboxStyle())
            .accessibilityIdentifier("todayChore")
            NavigationLink(value: chore) {
                Image(systemName: "chevron.right")
                    .fontWeight(.medium)
                    .imageScale(.medium)
                    .foregroundStyle(SbuTheme.inkMuted)
                    .frame(minWidth: SbuTheme.controlRoundSm, minHeight: SbuTheme.controlRoundSm)
                    .contentShape(.rect)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(Text("Apri \(item.chore.name)"))
            .accessibilityIdentifier("chore")
        }
    }

    /// "6 GIORNI DI RITARDO · MEDIO", or "FATTA OGGI" once ticked.
    private var metadata: some View {
        let due = item.isDone ? Text("Fatta oggi") : Text(DueLabel(item.state).text)
        return (due + Text(verbatim: " · ") + Text(item.chore.effort.name))
            .font(.sbuCartiglio)
            .monospacedDigit()
            .foregroundStyle(SbuTheme.inkMuted)
    }

    private var isDone: Binding<Bool> {
        Binding { item.isDone } set: { setDone(chore, $0) }
    }
}

#Preview("Light") {
    TodayChoreRowPreview()
}

#Preview("Dark") {
    TodayChoreRowPreview()
        .preferredColorScheme(.dark)
}

private struct TodayChoreRowPreview: View {
    var body: some View {
        let now = Date.now
        let chore = Chore(name: "Pulire il WC", frequency: Frequency(7, .day), effort: .medium, lastDone: now.addingTimeInterval(-9 * 86_400))
        let state = chore.state(at: now, calendar: .current)
        let items = [TodayList.Item(chore: chore.snapshot, state: state), TodayList.Item(chore: chore.snapshot, state: state, isDone: true)]
        NavigationStack {
            ScrollView {
                VStack(spacing: SbuTheme.space4) {
                    ForEach(items.indices, id: \.self) { index in
                        TodayChoreRow(item: items[index], chore: chore) { _, _ in }
                    }
                }
                .padding(SbuTheme.space4)
            }
            .sbuPaper()
        }
        .modelContainer(.preview)
    }
}
