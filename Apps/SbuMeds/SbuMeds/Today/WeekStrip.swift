import SbuKit
import SwiftUI

/// The week as on Medisafe's home: seven days to pick from, with the weeks before and after one
/// tap away. At the accessibility sizes, one day with arrows, so nothing is cut.
struct WeekStrip: View {
    @Binding var selection: Day
    let today: Day

    @Environment(\.calendar) private var calendar
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        HStack(spacing: 0) {
            Button("Settimana prima", systemImage: "chevron.left") { move(by: -step) }
                .labelStyle(.iconOnly)
                .frame(minWidth: SbuTheme.controlRoundSm, minHeight: SbuTheme.controlRoundSm)
                .contentShape(.rect)
                .tint(SbuTheme.ink)
                .accessibilityIdentifier("previousWeek")
            if dynamicTypeSize.isAccessibilitySize {
                Text(selection.start(in: calendar), format: .dateTime.weekday(.wide).day().month(.wide))
                    .font(SbuTheme.headline)
                    .foregroundStyle(SbuTheme.ink)
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)
            } else {
                ForEach(selection.week(in: calendar), id: \.self) { day in
                    DayButton(day: day, isSelected: day == selection, isToday: day == today) { selection = day }
                }
            }
            Button("Settimana dopo", systemImage: "chevron.right") { move(by: step) }
                .labelStyle(.iconOnly)
                .frame(minWidth: SbuTheme.controlRoundSm, minHeight: SbuTheme.controlRoundSm)
                .contentShape(.rect)
                .tint(SbuTheme.ink)
                .accessibilityIdentifier("nextWeek")
        }
        .buttonStyle(.borderless)
        .fontWeight(.medium)
        .padding(.vertical, SbuTheme.space2)
    }

    private var step: Int { dynamicTypeSize.isAccessibilitySize ? 1 : 7 }

    private func move(by days: Int) {
        selection = selection.adding(days: days, in: calendar)
    }
}

/// One day of the strip: its weekday initial and its number, filled in ink when picked.
private struct DayButton: View {
    let day: Day
    let isSelected: Bool
    let isToday: Bool
    let select: () -> Void

    @Environment(\.calendar) private var calendar

    var body: some View {
        Button(action: select) {
            VStack(spacing: SbuTheme.space1) {
                Text(date, format: .dateTime.weekday(.narrow))
                    .font(SbuTheme.caption)
                    .foregroundStyle(SbuTheme.inkMuted)
                Text(date, format: .dateTime.day())
                    .font(SbuTheme.headline)
                    .monospacedDigit()
                    .foregroundStyle(isSelected ? SbuTheme.paper : SbuTheme.ink)
                    .frame(minWidth: SbuTheme.space8, minHeight: SbuTheme.space8)
                    .background {
                        if isSelected {
                            Circle().fill(SbuTheme.ink)
                        } else if isToday {
                            Circle().stroke(SbuTheme.line, lineWidth: SbuTheme.hairline)
                        }
                    }
            }
            .frame(maxWidth: .infinity)
            .contentShape(.rect)
        }
        .accessibilityLabel(Text(date, format: .dateTime.weekday(.wide).day().month(.wide)))
        .accessibilityValue(isToday ? Text("Oggi") : Text(verbatim: ""))
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .accessibilityIdentifier("day")
    }

    private var date: Date { day.start(in: calendar) }
}

#Preview("Light") {
    WeekStripPreview()
}

#Preview("Dark") {
    WeekStripPreview()
        .preferredColorScheme(.dark)
}

private struct WeekStripPreview: View {
    @State private var selection = Day(.now, calendar: .current)

    var body: some View {
        WeekStrip(selection: $selection, today: Day(.now, calendar: .current))
            .padding(SbuTheme.space4)
            .frame(maxHeight: .infinity, alignment: .top)
            .background(SbuTheme.paper)
            .environment(\.sbuAccent, .meds)
    }
}
