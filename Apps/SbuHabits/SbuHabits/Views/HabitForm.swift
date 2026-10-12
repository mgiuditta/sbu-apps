import SbuKit
import SwiftUI

/// The form that creates or edits a habit: a title, how many times a day, which days, and a symbol.
/// Editing never rewrites the log, and offers Elimina.
struct HabitForm: View {
    private enum Kind {
        case everyDay, weekdays, timesPerWeek
    }

    @Environment(\.dismiss) private var dismiss

    let model: HabitsModel
    /// The habit to edit, or `nil` to add a new one.
    let habit: Habit?

    @State private var title: String
    @State private var symbol: String
    @State private var timesPerDay: Int
    @State private var kind: Kind
    @State private var weekdays: Set<Int>
    @State private var timesPerWeek: Int

    private var schedule: Schedule {
        switch kind {
        case .everyDay: .everyDay
        case .weekdays: .weekdays(weekdays)
        case .timesPerWeek: .timesPerWeek(timesPerWeek)
        }
    }

    private var formTitle: LocalizedStringKey {
        habit == nil ? "Nuova abitudine" : "Modifica abitudine"
    }

    private var confirmTitle: LocalizedStringKey {
        habit == nil ? "Aggiungi" : "Salva"
    }

    private var canAdd: Bool {
        title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false && schedule != .weekdays([])
    }

    init(model: HabitsModel, editing habit: Habit? = nil) {
        self.model = model
        self.habit = habit
        _title = State(initialValue: habit?.title ?? "")
        _symbol = State(initialValue: habit?.symbol ?? HabitSymbol.all[0].id)
        _timesPerDay = State(initialValue: habit?.timesPerDay ?? 1)
        switch habit?.schedule ?? .everyDay {
        case .everyDay:
            _kind = State(initialValue: .everyDay)
            _weekdays = State(initialValue: Set(1...7))
            _timesPerWeek = State(initialValue: 3)
        case .weekdays(let days):
            _kind = State(initialValue: .weekdays)
            _weekdays = State(initialValue: days)
            _timesPerWeek = State(initialValue: 3)
        case .timesPerWeek(let times):
            _kind = State(initialValue: .timesPerWeek)
            _weekdays = State(initialValue: Set(1...7))
            _timesPerWeek = State(initialValue: times)
        }
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

                if habit != nil {
                    Section {
                        SbuButton("Elimina", kind: .destructive, action: delete)
                    }
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                }
            }
            .navigationTitle(formTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annulla", action: cancel)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(confirmTitle, action: confirm)
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

    private func confirm() {
        if let habit {
            model.edit(habit, title: title, symbol: symbol, timesPerDay: timesPerDay, schedule: schedule)
        } else {
            model.add(title: title, symbol: symbol, timesPerDay: timesPerDay, schedule: schedule)
        }
        dismiss()
    }

    private func delete() {
        if let habit {
            model.delete(habit)
        }
        dismiss()
    }
}

#Preview("Light") {
    HabitForm(model: .preview)
        .tint(SbuTheme.accentHabits)
}

#Preview("Dark") {
    let model = HabitsModel.preview
    HabitForm(model: model, editing: model.habits[0])
        .tint(SbuTheme.accentHabits)
        .preferredColorScheme(.dark)
}
