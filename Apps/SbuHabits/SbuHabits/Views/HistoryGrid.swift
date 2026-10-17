import SbuKit
import SwiftUI

/// A habit's weeks since it began, up to the last 26, newest first, one column per weekday.
///
/// Done is a filled accent circle with a checkmark, skipped a forward mark, missed an empty
/// ring, and a day with nothing expected stays blank: state never rests on color alone.
/// With `openNote`, every day from the habit's start to today opens its Nota del giorno.
struct HistoryGrid: View {
    static let maxWeeks = 26

    @Environment(\.calendar) private var calendar

    let habit: Habit
    let today: LogicalDay
    let firstWeekday: Int
    /// Opens the Nota del giorno of a day; `nil` leaves the days still.
    var openNote: ((LogicalDay) -> Void)?

    private var columns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: SbuTheme.space1), count: 7)
    }

    private var days: [LogicalDay] {
        let thisWeek = today.weekStart(firstWeekday: firstWeekday)
        let firstWeek = habit.createdOn.weekStart(firstWeekday: firstWeekday)
        // A habit started "in the future", after the clock was moved back, still shows this week.
        let weeks = min(max((thisWeek.ordinal - firstWeek.ordinal) / 7 + 1, 1), Self.maxWeeks)
        return (0..<weeks).flatMap { week in
            (0..<7).map { thisWeek - week * 7 + $0 }
        }
    }

    var body: some View {
        LazyVGrid(columns: columns, spacing: SbuTheme.space1) {
            ForEach(0..<7, id: \.self) { offset in
                Text(calendar.veryShortStandaloneWeekdaySymbols[(firstWeekday - 1 + offset) % 7])
                    .font(SbuTheme.caption)
                    .foregroundStyle(SbuTheme.inkMuted)
                    .accessibilityHidden(true)
            }

            ForEach(days, id: \.self) { day in
                HistoryCell(state: DayState(of: habit, on: day, today: today), day: day, hasNote: habit.note(on: day) != nil, open: opener(for: day))
            }
        }
        .padding(.vertical, SbuTheme.space2)
    }

    /// Only the days the habit lived, today included: never one still to come.
    private func opener(for day: LogicalDay) -> (() -> Void)? {
        guard let openNote, day <= today, day >= habit.createdOn else { return nil }
        return { openNote(day) }
    }
}

private struct HistoryCell: View {
    @Environment(\.calendar) private var calendar

    let state: DayState
    let day: LogicalDay
    let hasNote: Bool
    /// Opens the day's note; `nil` for a day that has none to open.
    let open: (() -> Void)?

    @ScaledMetric(relativeTo: .body) private var side = SbuTheme.space6

    private var stateName: LocalizedStringKey {
        switch state {
        case .done: "Fatta"
        case .skipped: "Saltata"
        case .missed: "Mancata"
        case .empty: "Non prevista"
        }
    }

    private var value: Text {
        hasNote ? Text(stateName) + Text(verbatim: ", ") + Text("con nota") : Text(stateName)
    }

    var body: some View {
        if let open {
            Button(action: open) {
                mark
            }
            .buttonStyle(.plain)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(label)
            .accessibilityValue(value)
            .accessibilityAddTraits(.isButton)
            .accessibilityHint("Apre la nota del giorno")
        } else {
            mark
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(label)
                .accessibilityValue(value)
                .accessibilityHidden(state == .empty)
        }
    }

    private var label: Text {
        Text(day.noon(in: calendar), format: .dateTime.weekday(.wide).day().month(.wide))
    }

    private var mark: some View {
        ZStack {
            switch state {
            case .done:
                Circle()
                    .fill(.tint)
                Image(systemName: "checkmark")
                    .font(SbuTheme.caption.weight(.semibold))
                    .foregroundStyle(SbuTheme.onAccent)
            case .skipped:
                Image(systemName: "forward")
                    .font(SbuTheme.caption)
                    .foregroundStyle(SbuTheme.inkMuted)
            case .missed:
                Circle()
                    .strokeBorder(SbuTheme.line, lineWidth: SbuTheme.hairline * 2)
            case .empty:
                Color.clear
            }
        }
        // As large as the text size asks, never wider than its column: at accessibility sizes
        // seven fixed circles would overlap their neighbours.
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .aspectRatio(1, contentMode: .fit)
        .frame(maxWidth: side)
        .frame(maxWidth: .infinity)
        .contentShape(.rect)
    }
}

#Preview("Light") {
    HistoryGridPreview()
}

#Preview("Dark") {
    HistoryGridPreview()
        .preferredColorScheme(.dark)
}

private struct HistoryGridPreview: View {
    var body: some View {
        let today = LogicalDay(.now)
        var habit = Habit(title: "Leggere", symbol: "book", schedule: .weekdays([2, 3, 4, 5, 6]), createdOn: today - 120)
        for daysAgo in stride(from: 1, to: 100, by: 1) where daysAgo % 5 != 0 {
            habit.log[today - daysAgo] = 1
        }
        habit.skipped = [today - 10, today - 25]
        return List {
            HistoryGrid(habit: habit, today: today, firstWeekday: 2)
        }
        .tint(SbuTheme.ink)
    }
}
