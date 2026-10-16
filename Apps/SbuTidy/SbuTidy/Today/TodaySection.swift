import SbuKit
import SwiftUI

/// One room in the to-do list: its name and count, then its chores, each opening its screen and
/// marked done with a swipe, as in Tody.
struct TodaySection: View {
    let section: TodayList.Section
    let chores: [UUID: Chore]
    let markDone: (Chore) -> Void

    var body: some View {
        Section {
            ForEach(section.items) { item in
                if let chore = chores[item.id] {
                    NavigationLink(value: chore) {
                        ChoreRow(name: item.chore.name, effort: item.chore.effort, state: item.state)
                    }
                    .swipeActions(edge: .leading, allowsFullSwipe: true) {
                        DoneButton { markDone(chore) }
                    }
                    .contextMenu {
                        DoneButton { markDone(chore) }
                    }
                    .accessibilityIdentifier("chore")
                }
            }
            .listRowBackground(SbuTheme.surfaceRaised)
        } header: {
            HStack {
                Text(section.roomName)
                Spacer()
                Text(section.items.count, format: .number)
                    .monospacedDigit()
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
    private let now = Date.now

    var body: some View {
        let room = UUID()
        let chores = [7.0, 3, 12].enumerated().map { index, age in
            ChoreSnapshot(id: UUID(), name: "Attività \(index + 1)", roomID: room, roomName: "Cucina", roomOrder: 0, effort: .medium,
                          frequency: Frequency(5, .day), clock: ChoreClock(lastDone: now.addingTimeInterval(-age * 86_400)))
        }
        return List {
            ForEach(TodayList(chores, filter: .toDo, now: now, calendar: .current).sections) { section in
                TodaySection(section: section, chores: [:]) { _ in }
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(SbuTheme.surface)
    }
}
