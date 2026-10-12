import SbuKit
import SwiftUI

/// The form that creates a habit: a title, how many times a day, which days, and a symbol.
struct AddHabitView: View {
    private enum Kind {
        case everyDay, weekdays, timesPerWeek
    }

    @Environment(\.dismiss) private var dismiss

    let model: HabitsModel

    @State private var title = ""
    @State private var symbol = HabitSymbol.all[0].id
    @State private var timesPerDay = 1
    @State private var kind = Kind.everyDay
    @State private var weekdays: Set<Int> = Set(1...7)
    @State private var timesPerWeek = 3

    private var schedule: Schedule {
        switch kind {
        case .everyDay: .everyDay
        case .weekdays: .weekdays(weekdays)
        case .timesPerWeek: .timesPerWeek(timesPerWeek)
        }
    }

    private var canAdd: Bool {
        title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false && schedule != .weekdays([])
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Titolo", text: $title)
                        .onChange(of: title, limitTitle)

                    // A weekly habit is done once a day: its count is the days of the week.
                    if kind != .timesPerWeek {
                        Stepper(value: $timesPerDay, in: Habit.timesPerDayRange) {
                            LabeledContent("Volte al giorno", value: timesPerDay, format: .number)
                        }
                    }
                }

                Section("Programmazione") {
                    Picker("Programmazione", selection: $kind) {
                        Text("Ogni giorno").tag(Kind.everyDay)
                        Text("Giorni della settimana").tag(Kind.weekdays)
                        Text("Volte a settimana").tag(Kind.timesPerWeek)
                    }
                    .pickerStyle(.inline)
                    .labelsHidden()

                    switch kind {
                    case .everyDay:
                        EmptyView()
                    case .weekdays:
                        WeekdayPicker(selection: $weekdays)
                    case .timesPerWeek:
                        Stepper(value: $timesPerWeek, in: Schedule.timesPerWeekRange) {
                            LabeledContent("Volte a settimana", value: timesPerWeek, format: .number)
                        }
                    }
                }

                Section("Simbolo") {
                    SymbolPicker(selection: $symbol)
                }
            }
            .navigationTitle("Nuova abitudine")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annulla", action: cancel)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Aggiungi", action: add)
                        .disabled(canAdd == false)
                }
            }
        }
    }

    private func limitTitle() {
        if title.count > Habit.maxTitleLength {
            title = String(title.prefix(Habit.maxTitleLength))
        }
    }

    private func cancel() {
        dismiss()
    }

    private func add() {
        model.add(title: title, symbol: symbol, timesPerDay: timesPerDay, schedule: schedule)
        dismiss()
    }
}

#Preview("Light") {
    AddHabitView(model: .preview)
        .tint(SbuTheme.accentHabits)
}

#Preview("Dark") {
    AddHabitView(model: .preview)
        .tint(SbuTheme.accentHabits)
        .preferredColorScheme(.dark)
}
