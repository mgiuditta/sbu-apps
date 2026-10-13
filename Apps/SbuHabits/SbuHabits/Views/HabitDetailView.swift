import SbuKit
import SwiftUI

/// One habit's page: its Serie as the figure, the best one, its history, and its notes. A day
/// in the history, or a note, opens that day's Nota del giorno.
struct HabitDetailView: View {
    @Environment(\.calendar) private var calendar

    let model: HabitsModel
    let habit: Habit

    /// The day whose note is open.
    @State private var noteDay: LogicalDay?

    /// The notes, newest first.
    private var notes: [(day: LogicalDay, text: String)] {
        habit.notes.sorted { $0.key > $1.key }.map { (day: $0.key, text: $0.value) }
    }

    private var unit: String {
        let streak = model.streak(of: habit)
        let word = switch habit.schedule.period {
        case .week: streak == 1 ? String(localized: "settimana") : String(localized: "settimane")
        case .month: streak == 1 ? String(localized: "mese") : String(localized: "mesi")
        case nil: streak == 1 ? String(localized: "giorno") : String(localized: "giorni")
        }
        return " " + word
    }

    var body: some View {
        List {
            Section {
                SbuStat("Serie", value: model.streak(of: habit), format: .number, unit: unit, context: "Serie migliore: \(model.bestStreak(of: habit))")
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
            }

            Section {
                HistoryGrid(habit: habit, today: model.today, firstWeekday: model.firstWeekday, openNote: openNote)
            } header: {
                Text("Storico")
            } footer: {
                Text("Tocca un giorno per scriverne la nota.")
            }

            if notes.isEmpty == false {
                Section("Note") {
                    ForEach(notes, id: \.day) { note in
                        Button {
                            openNote(note.day)
                        } label: {
                            NoteRow(day: note.day, text: note.text)
                        }
                    }
                }
            }
        }
        .sheet(item: $noteDay) { day in
            DailyNoteEditor(model: model, habit: habit, day: day)
                .tint(SbuTheme.accentHabits)
        }
        .listStyle(.insetGrouped)
        .navigationTitle(Text(habit.title))
        .navigationBarTitleDisplayMode(.inline)
    }

    private func openNote(_ day: LogicalDay) {
        noteDay = day
    }
}

#Preview("Light") {
    let model = HabitsModel.preview
    NavigationStack {
        HabitDetailView(model: model, habit: model.habits[1])
    }
    .tint(SbuTheme.accentHabits)
}

#Preview("Dark") {
    let model = HabitsModel.preview
    NavigationStack {
        HabitDetailView(model: model, habit: model.habits[1])
    }
    .tint(SbuTheme.accentHabits)
    .preferredColorScheme(.dark)
}
