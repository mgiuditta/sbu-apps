import SbuKit
import SwiftUI

/// One page of the Statistiche, every habit or one: the completion rate as the figure, the line
/// of completion over time, the completions by weekday and by hour. A habit's page goes on with
/// its Serie, its history and its notes, where a day opens its Nota del giorno.
struct StatisticsPage: View {
    let model: HabitsModel
    /// `nil` for the page of every habit.
    let habit: Habit?
    let statistics: HabitStatistics
    /// The page on show, the only one whose figure has the full stop.
    let isCurrent: Bool

    /// The day whose note is open.
    @State private var noteDay: LogicalDay?

    var body: some View {
        ScrollView {
            VStack(spacing: SbuTheme.space6) {
                Group {
                    if let habit {
                        Text(habit.title)
                    } else {
                        Text("Tutte le abitudini")
                    }
                }
                .font(SbuTheme.headline)
                .foregroundStyle(SbuTheme.ink)
                .multilineTextAlignment(.center)
                .accessibilityAddTraits(.isHeader)

                StatisticsFigure(statistics: statistics, streakSchedule: habit?.schedule ?? .everyDay, showsFullStop: isCurrent)

                Separator()

                CompletionLineChart(statistics: statistics)

                Separator()

                CompletionsSection(statistics: statistics, isAvoided: habit?.limit != nil)

                if let habit {
                    Separator()

                    HabitHistorySection(habit: habit, streak: model.streak(of: habit), today: model.today, firstWeekday: model.firstWeekday, openNote: openNote)
                }
            }
            .padding(.horizontal, SbuTheme.space4)
            .padding(.vertical, SbuTheme.space6)
        }
        .scrollBounceBehavior(.basedOnSize)
        .sheet(item: $noteDay) { day in
            if let habit {
                DailyNoteEditor(model: model, habit: habit, day: day)
                    .tint(SbuTheme.accentHabits)
            }
        }
    }

    private func openNote(_ day: LogicalDay) {
        noteDay = day
    }
}

/// A hairline between the parts of a Statistiche page.
private struct Separator: View {
    var body: some View {
        Rectangle()
            .fill(SbuTheme.line)
            .frame(height: SbuTheme.hairline)
            .accessibilityHidden(true)
    }
}

#Preview("Light") {
    let model = HabitsModel.preview
    StatisticsPage(model: model, habit: nil, statistics: .all(model.habits, period: .all, today: model.today, firstWeekday: model.firstWeekday), isCurrent: true)
        .background(SbuTheme.surface)
        .tint(SbuTheme.accentHabits)
}

#Preview("Dark") {
    let model = HabitsModel.preview
    let habit = model.habits[1]
    StatisticsPage(model: model, habit: habit, statistics: .habit(habit, period: .all, today: model.today, firstWeekday: model.firstWeekday), isCurrent: true)
        .background(SbuTheme.surface)
        .tint(SbuTheme.accentHabits)
        .preferredColorScheme(.dark)
}
