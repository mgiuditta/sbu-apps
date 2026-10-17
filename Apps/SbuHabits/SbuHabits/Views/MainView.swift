import SbuKit
import SwiftUI

/// The tool screen: the title and its cartiglio, the Serie piena as the one figure, today's
/// habits in a card under OGGI with Aggiungi after it, the habits that only tomorrow asks for
/// under DOMANI, and at the bottom the settings gear and Statistiche.
///
/// The full stop waits while today still asks for something, and is set once today is done. When
/// the last habit of today gets done the figure closes with "Fatto", once a day.
struct MainView: View {
    @Environment(\.scenePhase) private var scenePhase

    let model: HabitsModel
    /// The Abitudini condivise received, shown after the user's own habits.
    var received: ReceivedHabits?
    let present: (HabitSheet) -> Void

    @State private var isClosing = false
    /// The day the Closure last played: once a day, however often today is undone and done again.
    @State private var closedDay: LogicalDay?

    var body: some View {
        // Walks back through the whole log: once per render.
        let tally = model.todayTally
        let pages = model.homePages(shared: received?.habits ?? [])
        ScrollView {
            VStack(alignment: .leading, spacing: SbuTheme.space6) {
                SbuScreenTitle("Abitudini", cartiglio: cartiglio)
                figure(tally)
                HomeDayList(
                    model: model,
                    slots: pages.allSlots,
                    // The empty states offer Aggiungi themselves.
                    canAdd: pages.canAdd && model.todayHabits.isEmpty == false,
                    add: add,
                    edit: edit,
                    writeNote: writeNote,
                    openShared: openShared
                )
            }
            .padding(.horizontal, SbuTheme.space4)
            .padding(.vertical, SbuTheme.space6)
            // The grid scrolls with the page, so the figure stays on its line while it scrolls.
            .sbuPaper(grid: true)
        }
        .scrollBounceBehavior(.basedOnSize)
        .background(SbuTheme.paper)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            HomeBar(isStatisticsEnabled: model.habits.isEmpty == false, showStatistics: showStatistics)
                .padding(.horizontal, SbuTheme.space4)
                .padding(.vertical, SbuTheme.space2)
                .background(SbuTheme.paper)
        }
        .onChange(of: tally) { old, new in
            close(from: old, to: new)
        }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active {
                model.reload()
            }
        }
        // Habits linked to Salute mark themselves when the app comes back.
        .task(id: scenePhase) {
            if scenePhase == .active {
                await model.refreshFromHealth()
            }
        }
        // Moves the list to the new day while the app stays open.
        .task(id: model.today) {
            try? await Task.sleep(for: .seconds(max(model.nextDayStart.timeIntervalSinceNow, 1)))
            if Task.isCancelled == false {
                model.reload()
            }
        }
    }

    /// "Sbu · Abitudini · sab 17 ott", for the logical day on screen.
    private var cartiglio: String {
        let day = model.today.noon(in: .current).formatted(.dateTime.weekday(.abbreviated).day().month(.abbreviated))
        return String(localized: "Sbu · Abitudini · \(day)")
    }

    @ViewBuilder
    private func figure(_ tally: TodayTally) -> some View {
        if model.isUnreadable {
            SbuEmpty(sentence: "Le abitudini salvate non si aprono. Non vanno perse.")
        } else if model.habits.isEmpty {
            SbuEmpty(sentence: "Aggiungi la tua prima abitudine.") {
                Button("Aggiungi", action: add)
            }
        } else if model.todayHabits.isEmpty {
            SbuEmpty(sentence: "Niente previsto oggi.") {
                Button("Aggiungi", action: add)
            }
        } else {
            SbuFigure(
                value: tally.fullStreak.formatted(),
                fullStop: tally.isComplete && tally.fullStreak > 0 ? .set : .waiting,
                context: Self.context(of: tally),
                accessibilityLabel: Self.spoken(tally)
            )
            .sbuClosure($isClosing, word: "Fatto")
        }
    }

    /// "giorni di fila · 3 di 3 oggi"; only the Serie when today asks for nothing to do.
    private static func context(of tally: TodayTally) -> Text {
        // Two strings, as Xcode asks for plurals that omit the number.
        let streak = tally.fullStreak == 1 ? Text("giorno di fila") : Text("giorni di fila")
        guard tally.total > 0 else { return streak }
        return streak + Text(verbatim: " · ") + Text("\(tally.done) di \(tally.total) oggi")
    }

    /// "Serie piena, 12 giorni, 3 di 3 oggi".
    private static func spoken(_ tally: TodayTally) -> Text {
        var text = Text("Serie piena") + Text(verbatim: ", ") + Text("\(tally.fullStreak) giorni")
        if tally.total > 0 {
            text = text + Text(verbatim: ", ") + Text("\(tally.done) di \(tally.total) oggi")
        }
        return text
    }

    /// The Closure, when one more habit done completes today: never at launch, once a day.
    private func close(from old: TodayTally, to new: TodayTally) {
        guard new.isComplete, old.isComplete == false, new.done > old.done, closedDay != model.today else { return }
        closedDay = model.today
        isClosing = true
    }

    private func add() {
        present(.add)
    }

    private func edit(_ habit: Habit) {
        present(.edit(habit))
    }

    private func writeNote(_ habit: Habit) {
        present(.note(habit, model.today))
    }

    private func openShared(_ habit: ReceivedHabit) {
        present(.shared(habit))
    }

    private func showStatistics() {
        present(.statistics)
    }
}

#Preview("Light") {
    MainView(model: .preview, received: .preview) { _ in }
        .tint(SbuTheme.ink)
        .environment(\.sbuAccent, .habits)
}

#Preview("Dark") {
    MainView(model: .preview) { _ in }
        .tint(SbuTheme.ink)
        .environment(\.sbuAccent, .habits)
        .preferredColorScheme(.dark)
}
