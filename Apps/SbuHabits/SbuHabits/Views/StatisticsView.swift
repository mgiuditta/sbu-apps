import SbuKit
import SwiftUI

/// Statistiche, as Streaks lays them out: the period at the top, the habits' symbols, then pages
/// that swipe sideways, every habit first and then one per habit in the grid's order; at the
/// bottom Condividi, which shares the page on show as a picture, the pages and Chiudi.
///
/// The pager draws only the pages in view, and their numbers are kept until the habits, the
/// period or today change: only a page on show walks its history.
struct StatisticsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let model: HabitsModel

    @State private var period = StatisticsPeriod.all
    /// The page on show: 0 for every habit, then one per habit.
    @State private var page = 0
    @State private var cache = StatisticsCache()

    var body: some View {
        let habits = model.habits
        VStack(spacing: 0) {
            VStack(spacing: SbuTheme.space4) {
                PeriodMenu(period: $period)
                    .padding(.horizontal, SbuTheme.space4)

                HabitSymbolRow(habits: habits, page: page, select: turn(to:))
            }
            .padding(.top, SbuTheme.space6)
            .padding(.bottom, SbuTheme.space2)

            TabView(selection: $page) {
                ForEach(0...habits.count, id: \.self) { index in
                    CachedStatisticsPage(
                        model: model,
                        habit: index == 0 ? nil : habits[index - 1],
                        habits: habits,
                        period: period,
                        cache: cache,
                        isCurrent: index == page
                    )
                    .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))

            StatisticsBar(symbols: habits.map(\.symbol), page: page, share: share(of: habits), turn: turn(to:), close: close)
                .padding(.horizontal, SbuTheme.space4)
                .padding(.vertical, SbuTheme.space2)
        }
        .background(SbuTheme.surface)
    }

    /// The page on show over the period chosen, its numbers from the cache the page filled.
    private func share(of habits: [Habit]) -> StatisticsShare {
        let habit = StatisticsShare.habit(on: page, in: habits)
        let statistics = cache.statistics(of: habit, in: habits, period: period, today: model.today, firstWeekday: model.firstWeekday)
        return StatisticsShare(page: page, habits: habits, period: period, statistics: statistics)
    }

    /// Turns to a page from a symbol or the page indicator, sliding unless Reduce Motion is on.
    private func turn(to page: Int) {
        guard (0...model.habits.count).contains(page) else { return }
        withAnimation(reduceMotion ? nil : .snappy) {
            self.page = page
        }
    }

    private func close() {
        dismiss()
    }
}

/// A page that works out its numbers only when drawn, from the cache when it can: the pager
/// creates every page, but draws only the ones in view.
private struct CachedStatisticsPage: View {
    let model: HabitsModel
    let habit: Habit?
    let habits: [Habit]
    let period: StatisticsPeriod
    let cache: StatisticsCache
    let isCurrent: Bool

    var body: some View {
        StatisticsPage(
            model: model,
            habit: habit,
            statistics: cache.statistics(of: habit, in: habits, period: period, today: model.today, firstWeekday: model.firstWeekday),
            isCurrent: isCurrent
        )
    }
}

#Preview("Light") {
    StatisticsView(model: .preview)
        .tint(SbuTheme.accentHabits)
}

#Preview("Dark") {
    StatisticsView(model: .preview)
        .tint(SbuTheme.accentHabits)
        .preferredColorScheme(.dark)
}
