import SbuKit
import SwiftUI

/// The tool screen, as Streaks lays it out: the Serie piena as the figure on top, today's habits
/// in pages of six with Aggiungi last, and at the bottom the settings gear, the page dots and
/// Statistiche.
struct MainView: View {
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    let model: HabitsModel
    /// The Abitudini condivise received, shown after the user's own habits.
    var received: ReceivedHabits?
    let present: (HabitSheet) -> Void

    /// The page of the grid on screen; `nil` while a swipe is between two.
    @State private var page: Int? = 0

    private var context: LocalizedStringKey? {
        if model.isUnreadable {
            "Le abitudini salvate non si aprono. Non vanno perse."
        } else if model.habits.isEmpty {
            "Aggiungi la prima abitudine"
        } else if model.todayHabits.isEmpty {
            "Niente previsto oggi"
        } else if model.canAdd == false {
            // Aggiungi is gone from the grid: say why.
            "Hai \(HomePages.habitLimit) abitudini, il massimo. Per aggiungerne un'altra, eliminane una."
        } else {
            nil
        }
    }

    var body: some View {
        // Walks back through the whole log: once per render.
        let fullStreak = model.fullStreak
        let pages = model.homePages(shared: received?.habits ?? [])
        SbuToolField(
            "Serie piena",
            value: fullStreak,
            format: .number,
            unit: Self.unit(for: fullStreak),
            context: context
        ) {
            HabitGrid(model: model, pages: pages, page: $page, add: add, edit: edit, writeNote: writeNote, openShared: openShared)
                // All the free height goes to the rings, none to the tool screen's spacer.
                .layoutPriority(1)
        } pills: {
            HomeBar(
                // One column, no pages, at accessibility text sizes.
                pageCount: dynamicTypeSize.isAccessibilitySize ? 1 : pages.pages.count,
                page: $page,
                isStatisticsEnabled: model.habits.isEmpty == false,
                showStatistics: showStatistics
            )
        }
        // Rolls the figure's digits (SbuToolField sets .numericText) when the Serie piena changes.
        .animation(reduceMotion ? nil : .snappy, value: fullStreak)
        // A page whose habits went: show the last one left.
        .onChange(of: pages.pages.count) { _, _ in
            page = pages.clamped(page ?? 0)
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
        // Moves the grid to the new day while the app stays open.
        .task(id: model.today) {
            try? await Task.sleep(for: .seconds(max(model.nextDayStart.timeIntervalSinceNow, 1)))
            if Task.isCancelled == false {
                model.reload()
            }
        }
    }

    /// The word after the figure. Two strings, as Xcode asks for plurals that omit the number.
    private static func unit(for streak: Int) -> String {
        " " + (streak == 1 ? String(localized: "giorno") : String(localized: "giorni"))
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
        .background(SbuTheme.surface)
        .tint(SbuTheme.accentHabits)
}

#Preview("Dark") {
    MainView(model: .preview) { _ in }
        .background(SbuTheme.surface)
        .tint(SbuTheme.accentHabits)
        .preferredColorScheme(.dark)
}
