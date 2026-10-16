import SbuKit
import SwiftData
import SwiftUI

/// The tool screen, Tody's "Da fare": how many chores are due today, closed by the full stop,
/// then the chores of the filter grouped by room, the dirtiest first.
struct TodayView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.calendar) private var calendar
    @Environment(Clock.self) private var clock
    @Query private var chores: [Chore]
    @Query(sort: \Room.order) private var rooms: [Room]
    @AppStorage("today.filter") private var filter = TodayFilter.toDo
    @State private var isAddingRoom = false
    @State private var doneCount = 0

    var body: some View {
        let list = TodayList(chores.map(\.snapshot), filter: filter, now: clock.now, calendar: calendar)
        let byID = Dictionary(chores.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })
        List {
            Section {
                TodayFigure(toDoCount: list.toDoCount, overdueCount: list.overdueCount)
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
            }
            Section {
                Picker("Mostra", selection: $filter) {
                    ForEach(TodayFilter.allCases) { Text($0.title).tag($0) }
                }
                .pickerStyle(.segmented)
                .labelsHidden()
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
                .accessibilityIdentifier("filter")
            }
            if list.isEmpty, !rooms.isEmpty {
                TodayEmptyRow(filter: filter)
            }
            ForEach(list.sections) { section in
                TodaySection(section: section, chores: byID, markDone: markDone)
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .overlay {
            if rooms.isEmpty {
                FirstRoomView(addRoom: addRoom, addBaseRooms: addBaseRooms)
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                NavigationLink(value: Destination.rooms) {
                    Label("Stanze", systemImage: "square.split.2x2")
                }
                .tint(SbuTheme.ink)
                .accessibilityIdentifier("rooms")
            }
        }
        .navigationDestination(for: Destination.self) { _ in
            RoomsView()
        }
        .navigationDestination(for: Room.self) { room in
            RoomView(room: room)
        }
        .navigationDestination(for: Chore.self) { chore in
            ChoreView(chore: chore)
        }
        .sheet(isPresented: $isAddingRoom) {
            RoomForm(room: nil)
        }
        .sensoryFeedback(.success, trigger: doneCount)
    }

    private func markDone(_ chore: Chore) {
        chore.markDone(at: .now, in: modelContext)
        try? modelContext.save()
        clock.refresh()
        doneCount += 1
    }

    private func addRoom() {
        isAddingRoom = true
    }

    /// Tody's first run: the rooms most homes have, with their base chores.
    private func addBaseRooms() {
        for kind in FirstRoomView.baseRooms {
            Home.addRoom(RoomDraft(kind: kind), in: modelContext)
        }
        try? modelContext.save()
    }
}

#Preview("Light") {
    NavigationStack {
        TodayView()
    }
    .modelContainer(.preview)
    .environment(Clock())
    .tint(SbuTheme.accentTidy)
}

#Preview("Dark") {
    NavigationStack {
        TodayView()
    }
    .modelContainer(.preview)
    .environment(Clock())
    .tint(SbuTheme.accentTidy)
    .preferredColorScheme(.dark)
}
