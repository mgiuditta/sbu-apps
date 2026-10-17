import SbuKit
import SwiftData
import SwiftUI

/// The tool screen, Tody's "Da fare", on paper: the title and how many chores are due today,
/// closed by the full stop, then the chores of the filter grouped by room, the dirtiest first,
/// each with its box. Ticking the last one of today plays the Closure "In ordine", once a day.
struct TodayView: View {
    /// The rooms of "Usa le stanze di base", in this order.
    static let baseRooms: [RoomKind] = [.kitchen, .bathroom, .bedroom, .livingRoom]

    @Environment(\.modelContext) private var modelContext
    @Environment(\.calendar) private var calendar
    @Environment(Clock.self) private var clock
    @Query private var chores: [Chore]
    @Query(sort: \Room.order) private var rooms: [Room]
    @AppStorage("today.filter") private var filter = TodayFilter.toDo
    @State private var tickCount = 0
    @State private var isClosing = false
    /// The day the Closure last played: once a day, however often a tick is taken back and redone.
    @State private var closedDay: Date?

    var body: some View {
        let list = list(filter)
        let byID = Dictionary(chores.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })
        ScrollView {
            VStack(alignment: .leading, spacing: SbuTheme.space6) {
                TodayFigure(list: list, hasRooms: !rooms.isEmpty, isClosing: $isClosing, addBaseRooms: addBaseRooms)
                if !rooms.isEmpty {
                    Picker("Mostra", selection: $filter) {
                        ForEach(TodayFilter.allCases) { Text($0.title).tag($0) }
                    }
                    .pickerStyle(.segmented)
                    .labelsHidden()
                    .accessibilityIdentifier("filter")
                    if list.isEmpty, filter == .upcoming {
                        Text("Niente in scadenza questa settimana. Qui trovi quello che diventa da fare nei prossimi 7 giorni.")
                            .font(SbuTheme.subheadline)
                            .foregroundStyle(SbuTheme.inkMuted)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    ForEach(list.sections) { section in
                        TodaySection(section: section, chores: byID, setDone: setDone)
                    }
                }
            }
            .padding(.horizontal, SbuTheme.space4)
            .padding(.vertical, SbuTheme.gridCell)
            .frame(maxWidth: .infinity, alignment: .leading)
            // The grid scrolls with the page, so the figure stays on its line while it scrolls.
            .sbuPaper(grid: true)
        }
        .scrollBounceBehavior(.basedOnSize)
        .background(SbuTheme.paper)
        .sbuAffectsFigure(tickCount)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                NavigationLink(value: Destination.rooms) {
                    Label("Stanze", systemImage: "square.split.2x2")
                }
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
    }

    private func list(_ filter: TodayFilter) -> TodayList {
        let doneToday = Set(chores.filter { $0.completion(on: clock.now, calendar: calendar) != nil }.map(\.id))
        return TodayList(chores.map(\.snapshot), filter: filter, now: clock.now, calendar: calendar, doneToday: doneToday)
    }

    /// The box: ticked, the chore is done now; unticked, today's completion goes back out of the history.
    private func setDone(_ chore: Chore, _ isDone: Bool) {
        let before = list(.toDo).toDoCount
        if isDone {
            chore.markDone(at: .now, in: modelContext)
        } else if let completion = chore.completion(on: clock.now, calendar: calendar) {
            chore.remove(completion, in: modelContext)
        }
        try? modelContext.save()
        clock.refresh()
        tickCount += 1
        close(from: before)
    }

    /// The Closure, when a tick leaves nothing to do today: never at launch, once a day.
    private func close(from before: Int) {
        let today = calendar.startOfDay(for: clock.now)
        guard before > 0, list(.toDo).toDoCount == 0, closedDay != today else { return }
        closedDay = today
        isClosing = true
    }

    /// Tody's first run: the rooms most homes have, with their base chores.
    private func addBaseRooms() {
        for kind in Self.baseRooms {
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
    .environment(\.sbuAccent, .tidy)
}

#Preview("Dark") {
    NavigationStack {
        TodayView()
    }
    .modelContainer(.preview)
    .environment(Clock())
    .environment(\.sbuAccent, .tidy)
    .preferredColorScheme(.dark)
}
