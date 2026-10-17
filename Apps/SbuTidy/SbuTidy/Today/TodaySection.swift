import SbuKit
import SwiftUI

/// One room in the to-do list, on paper: its name and count in mono, then its chores in a card,
/// each ticked as done with its box and opened with its chevron.
struct TodaySection: View {
    let section: TodayList.Section
    let chores: [UUID: Chore]
    let setDone: (Chore, Bool) -> Void

    @Environment(\.locale) private var locale
    @ScaledMetric(relativeTo: .caption2) private var labelSize = SbuTheme.cartiglioSize

    var body: some View {
        VStack(alignment: .leading, spacing: SbuTheme.space2) {
            // Uppercased in the string, as the cartiglio: the accessibility audit measures the string.
            Text(verbatim: "\(section.roomName.uppercased(with: locale)) · \(section.items.count.formatted())")
                .font(.sbuCartiglio)
                .tracking(labelSize * SbuTheme.cartiglioTracking)
                .foregroundStyle(SbuTheme.inkMuted)
                .accessibilityAddTraits(.isHeader)
            SbuListCard(section.items) { item in
                if let chore = chores[item.id] {
                    TodayChoreRow(item: item, chore: chore, setDone: setDone)
                }
            }
        }
    }
}

#Preview("Light") {
    TodaySectionPreview()
}

#Preview("Dark") {
    TodaySectionPreview()
        .preferredColorScheme(.dark)
}

private struct TodaySectionPreview: View {
    var body: some View {
        let now = Date.now
        let chores = [7.0, 3, 12].enumerated().map { index, age in
            Chore(name: "Attività \(index + 1)", frequency: Frequency(5, .day), effort: .medium, lastDone: now.addingTimeInterval(-age * 86_400))
        }
        let byID = Dictionary(uniqueKeysWithValues: chores.map { ($0.id, $0) })
        NavigationStack {
            ScrollView {
                VStack(spacing: SbuTheme.space6) {
                    ForEach(TodayList(chores.map(\.snapshot), filter: .toDo, now: now, calendar: .current).sections) { section in
                        TodaySection(section: section, chores: byID) { _, _ in }
                    }
                }
                .padding(SbuTheme.space4)
            }
            .sbuPaper()
        }
        .modelContainer(.preview)
    }
}
