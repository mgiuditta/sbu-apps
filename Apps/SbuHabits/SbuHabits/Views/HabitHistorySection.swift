import SbuKit
import SwiftUI

/// The bottom of a habit's Statistiche page, what its own page used to hold: the Serie it is on
/// and its history, where a day opens its Nota del giorno, then its notes, newest first.
struct HabitHistorySection: View {
    let habit: Habit
    let streak: Int
    let today: LogicalDay
    let firstWeekday: Int
    /// Opens a day's Nota del giorno; `nil` for an Abitudine condivisa received, read only.
    let openNote: ((LogicalDay) -> Void)?

    /// The notes, newest first.
    private var notes: [(day: LogicalDay, text: String)] {
        habit.notes.sorted { $0.key > $1.key }.map { (day: $0.key, text: $0.value) }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: SbuTheme.space6) {
            VStack(alignment: .leading, spacing: SbuTheme.space2) {
                SectionCaption(title: "Storico")

                VStack(spacing: SbuTheme.space3) {
                    LabeledContent {
                        Text(habit.schedule.streakText(streak))
                            .monospacedDigit()
                            .foregroundStyle(SbuTheme.inkMuted)
                    } label: {
                        Text("Serie")
                            .foregroundStyle(SbuTheme.ink)
                    }
                    .font(SbuTheme.body)

                    Rectangle()
                        .fill(SbuTheme.line)
                        .frame(height: SbuTheme.hairline)
                        .accessibilityHidden(true)

                    HistoryGrid(habit: habit, today: today, firstWeekday: firstWeekday, openNote: openNote)
                }
                .padding(SbuTheme.space4)
                .background(SbuTheme.surfaceRaised, in: .rect(cornerRadius: SbuTheme.radiusLg))

                if openNote != nil {
                    Text("Tocca un giorno per scriverne la nota.")
                        .font(SbuTheme.footnote)
                        .foregroundStyle(SbuTheme.inkMuted)
                        .padding(.horizontal, SbuTheme.space4)
                }
            }

            if notes.isEmpty == false {
                VStack(alignment: .leading, spacing: SbuTheme.space2) {
                    SectionCaption(title: "Note")

                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(Array(notes.enumerated()), id: \.element.day) { index, note in
                            if index > 0 {
                                Rectangle()
                                    .fill(SbuTheme.line)
                                    .frame(height: SbuTheme.hairline)
                                    .padding(.leading, SbuTheme.space4)
                                    .accessibilityHidden(true)
                            }
                            Button {
                                openNote?(note.day)
                            } label: {
                                NoteRow(day: note.day, text: note.text)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.horizontal, SbuTheme.space4)
                                    .padding(.vertical, SbuTheme.space2)
                                    .contentShape(.rect)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .background(SbuTheme.surfaceRaised, in: .rect(cornerRadius: SbuTheme.radiusLg))
                }
            }
        }
    }
}

/// The uppercase caption over a group of a Statistiche page, as a list section header.
private struct SectionCaption: View {
    let title: LocalizedStringKey

    var body: some View {
        Text(title)
            .font(SbuTheme.caption)
            .textCase(.uppercase)
            .tracking(SbuTheme.captionTracking)
            .foregroundStyle(SbuTheme.inkMuted)
            .padding(.horizontal, SbuTheme.space4)
            .accessibilityAddTraits(.isHeader)
    }
}

#Preview("Light") {
    HabitHistorySectionPreview()
}

#Preview("Dark") {
    HabitHistorySectionPreview()
        .preferredColorScheme(.dark)
}

private struct HabitHistorySectionPreview: View {
    var body: some View {
        let today = LogicalDay(.now)
        var habit = Habit(title: "Leggere", symbol: "book", createdOn: today - 40)
        for daysAgo in 1..<40 where daysAgo % 6 != 0 {
            habit.log[today - daysAgo] = 1
        }
        habit.setNote("Venti pagine prima di dormire.", on: today - 2)
        return ScrollView {
            HabitHistorySection(habit: habit, streak: 5, today: today, firstWeekday: 2) { _ in }
                .padding(SbuTheme.space4)
        }
        .background(SbuTheme.surface)
        .tint(SbuTheme.accentHabits)
    }
}
