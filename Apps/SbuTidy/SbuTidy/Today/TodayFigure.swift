import SbuKit
import SwiftUI

/// The figure zone of the tool screen, on the paper's grid: the title and its cartiglio, then the
/// chores to do today, late ones included. The full stop waits while some remain and is set once
/// today's are all done. With no room yet, or nothing to do and nothing done, the empty state
/// takes the figure's place. The last chore of today done plays the Closure "In ordine".
struct TodayFigure: View {
    let list: TodayList
    let hasRooms: Bool
    @Binding var isClosing: Bool
    let addBaseRooms: () -> Void

    @Environment(Clock.self) private var clock

    var body: some View {
        VStack(alignment: .leading, spacing: SbuTheme.space6) {
            SbuScreenTitle("Casa", cartiglio: cartiglio)
            zone
                // On the zone, not the figure: a one-off chore done last leaves the empty state behind.
                .sbuClosure($isClosing, word: "In ordine")
        }
    }

    @ViewBuilder
    private var zone: some View {
        if !hasRooms {
            SbuEmpty(sentence: "Inizia dalle stanze: ognuna arriva con le sue attività di base.") {
                Button("Usa le stanze di base", action: addBaseRooms)
                    .accessibilityIdentifier("addBaseRooms")
            }
        } else if list.toDoCount == 0, !list.isDayClosed {
            SbuEmpty(sentence: "Niente da fare oggi. Le attività tornano qui quando sono da fare.")
        } else {
            SbuFigure(
                value: list.toDoCount.formatted(),
                fullStop: list.isDayClosed ? .set : .waiting,
                context: Text(context),
                accessibilityLabel: Text("Da fare oggi: \(list.toDoCount). \(Text(context))")
            )
            .accessibilityIdentifier("todayFigure")
        }
    }

    /// "Sbu · Casa · sab 17 ott".
    private var cartiglio: String {
        let day = clock.now.formatted(.dateTime.weekday(.abbreviated).day().month(.abbreviated))
        return ["Sbu", String(localized: "Casa"), day].joined(separator: " · ")
    }

    private var context: LocalizedStringKey {
        if list.isDayClosed { return "Casa in ordine" }
        if list.overdueCount > 0 { return "da fare oggi · \(list.overdueCount) in ritardo" }
        return "da fare oggi"
    }
}

#Preview("Light") {
    TodayFigurePreview()
}

#Preview("Dark") {
    TodayFigurePreview()
        .preferredColorScheme(.dark)
}

private struct TodayFigurePreview: View {
    @State private var isClosing = false

    var body: some View {
        let now = Date.now
        let late = ChoreSnapshot(id: UUID(), name: "Pulire il WC", roomID: UUID(), roomName: "Bagno", roomOrder: 0, effort: .medium,
                                 frequency: Frequency(7, .day), clock: ChoreClock(lastDone: now.addingTimeInterval(-9 * 86_400)))
        ScrollView {
            VStack(alignment: .leading, spacing: SbuTheme.space12) {
                TodayFigure(list: TodayList([late], filter: .toDo, now: now, calendar: .current), hasRooms: true, isClosing: $isClosing) {}
                TodayFigure(list: TodayList([], filter: .toDo, now: now, calendar: .current), hasRooms: false, isClosing: $isClosing) {}
            }
            .padding(SbuTheme.space4)
            .sbuPaper(grid: true)
        }
        .environment(Clock())
        .environment(\.sbuAccent, .tidy)
    }
}
