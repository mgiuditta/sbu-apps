import SbuKit
import SwiftUI

/// The form that creates a habit: a title, how many times a day, which days, and a symbol.
struct AddHabitView: View {
    @Environment(\.dismiss) private var dismiss

    let model: HabitsModel

    @State private var title = ""
    @State private var symbol = HabitSymbol.all[0].id
    @State private var timesPerDay = 1
    @State private var isEveryDay = true
    @State private var weekdays: Set<Int> = Set(1...7)

    private var canAdd: Bool {
        title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false && (isEveryDay || weekdays.isEmpty == false)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Titolo", text: $title)
                        .onChange(of: title, limitTitle)

                    Stepper(value: $timesPerDay, in: Habit.timesPerDayRange) {
                        LabeledContent("Volte al giorno", value: timesPerDay, format: .number)
                    }
                }

                Section("Programmazione") {
                    Picker("Programmazione", selection: $isEveryDay) {
                        Text("Ogni giorno").tag(true)
                        Text("Giorni della settimana").tag(false)
                    }
                    .pickerStyle(.inline)
                    .labelsHidden()

                    if isEveryDay == false {
                        WeekdayPicker(selection: $weekdays)
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
        model.add(title: title, symbol: symbol, timesPerDay: timesPerDay, schedule: isEveryDay ? .everyDay : .weekdays(weekdays))
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
