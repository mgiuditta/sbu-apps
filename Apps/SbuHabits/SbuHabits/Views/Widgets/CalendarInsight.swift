import SbuKit
import SwiftUI

/// This month day by day, seven to a row from the 1st, as in Streaks: a full accent dot for a day
/// done, a cross for a miss, the skip mark for a day skipped, an accent ring for today and a
/// faint dot for the rest. The shapes differ, so the state never rests on color alone.
struct CalendarInsight: View {
    private static let columns = 7

    let dots: [CalendarDot]

    private var rows: Int {
        (dots.count + Self.columns - 1) / Self.columns
    }

    /// Days done, missed and skipped this month, for VoiceOver.
    private var summary: Text {
        let done = dots.count { $0.state == .done }
        let missed = dots.count { $0.state == .missed }
        let skipped = dots.count { $0.state == .skipped }
        return Text("\(done) giorni fatti") + Text(verbatim: ", ") + Text("\(missed) giorni mancati") + Text(verbatim: ", ") + Text("\(skipped) giorni saltati")
    }

    var body: some View {
        GeometryReader { proxy in
            let gap = SbuTheme.space1
            let cell = min(proxy.size.width / CGFloat(Self.columns), proxy.size.height / CGFloat(max(rows, 1)))
            let side = cell - gap
            VStack(alignment: .leading, spacing: gap) {
                ForEach(0..<rows, id: \.self) { row in
                    HStack(spacing: 0) {
                        ForEach(dots[(row * Self.columns)..<min((row + 1) * Self.columns, dots.count)]) { dot in
                            CalendarDotMark(state: dot.state)
                                .frame(width: side, height: side)
                                .frame(width: proxy.size.width / CGFloat(Self.columns))
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("Questo mese"))
        .accessibilityValue(summary)
    }
}

#Preview("Light") {
    CalendarInsightPreview()
}

#Preview("Dark") {
    CalendarInsightPreview()
        .preferredColorScheme(.dark)
}

private struct CalendarInsightPreview: View {
    var body: some View {
        let today = LogicalDay(.now)
        var habit = Habit(title: "Leggere", symbol: "book", createdOn: today - 40)
        for daysAgo in 1..<40 where daysAgo % 6 != 0 {
            habit.log[today - daysAgo] = 1
        }
        habit.skipped = [today - 6]
        return CalendarInsight(dots: MonthCalendar.dots(of: habit, today: today))
            .frame(width: 138, height: 90)
            .padding(SbuTheme.space4)
            .background(SbuTheme.paper)
            .tint(SbuTheme.ink)
    }
}
