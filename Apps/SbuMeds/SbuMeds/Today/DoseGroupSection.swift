import SbuKit
import SwiftUI

/// The doses due at one time: the time and "Prendi tutto" on top, then each dose, opened with a
/// tap and marked with a swipe.
struct DoseGroupSection: View {
    let group: DayPlan.Group
    /// Today and past days: a future dose is only shown.
    let canMark: Bool
    let open: (DoseItem) -> Void
    let takeAll: (DayPlan.Group) -> Void
    let mark: (DoseItem, DoseMark) -> Void

    var body: some View {
        Section {
            ForEach(group.items) { item in
                Button { open(item) } label: {
                    DoseRow(item: item)
                }
                .tint(SbuTheme.ink)
                .swipeActions(edge: .leading, allowsFullSwipe: true) {
                    if canMark, !item.isExtra, !item.state.isTaken {
                        Button("Presa", systemImage: "checkmark") { mark(item, .taken) }
                            .tint(SbuTheme.success)
                    }
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    if canMark, !item.isExtra, item.state != .skipped {
                        Button("Saltata", systemImage: "minus.circle") { mark(item, .skipped) }
                            .tint(SbuTheme.inkMuted)
                    }
                }
                .accessibilityIdentifier("dose")
            }
            .listRowBackground(SbuTheme.surfaceRaised)
        } header: {
            HStack(alignment: .firstTextBaseline) {
                Text(group.dueDate, format: .dateTime.hour().minute())
                    .monospacedDigit()
                Spacer()
                if canMark, group.toTake.count > 1 {
                    Button("Prendi tutto") { takeAll(group) }
                        .font(SbuTheme.subheadline.weight(.semibold))
                        .textCase(nil)
                        .frame(minHeight: SbuTheme.controlRoundSm)
                        .contentShape(.rect)
                        .accessibilityIdentifier("takeAll")
                }
            }
        }
    }
}

#Preview("Light") {
    DoseGroupSectionPreview()
}

#Preview("Dark") {
    DoseGroupSectionPreview()
        .preferredColorScheme(.dark)
}

private struct DoseGroupSectionPreview: View {
    var body: some View {
        let today = Day(.now, calendar: .current)
        let medicines = ["Ramipril", "Atorvastatina"].map { MedicineSnapshot(name: $0, schedule: Schedule(times: [DoseTime(hour: 23, minute: 59)], start: today)) }
        List {
            ForEach(DayPlan(medicines, day: today, now: .now, calendar: .current).groups) { group in
                DoseGroupSection(group: group, canMark: true, open: { _ in }, takeAll: { _ in }, mark: { _, _ in })
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(SbuTheme.surface)
        .tint(SbuTheme.accentMeds)
    }
}
