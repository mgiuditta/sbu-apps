import SbuKit
import SwiftUI

/// The form that creates or edits a habit: to do or to avoid, a title, how many times a day, a
/// countdown or the Limite, which days, a link to Salute, a symbol and reminder times. The kind is chosen once;
/// editing never rewrites the log, and offers Elimina.
struct HabitForm: View {
    private enum Kind {
        case everyDay, weekdays, timesPerWeek
    }

    @Environment(\.dismiss) private var dismiss

    let model: HabitsModel
    /// The habit to edit, or `nil` to add a new one.
    let habit: Habit?

    @State private var avoids: Bool
    @State private var limit: Int
    @State private var title: String
    @State private var symbol: String
    @State private var timesPerDay: Int
    @State private var kind: Kind
    @State private var weekdays: Set<Int>
    @State private var timesPerWeek: Int
    @State private var reminders: [RemindersSection.Row]
    @State private var linksHealth: Bool
    @State private var healthMeasure: HealthMeasure
    @State private var healthGoal: Double
    @State private var isTimed: Bool
    @State private var timerMinutes: Int

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

    private var healthLink: HealthLink? {
        linksHealth && avoids == false ? HealthLink(measure: healthMeasure, goal: healthGoal) : nil
    }

    /// The lengths the Durata picker offers, with the habit's own if a file brought another.
    private var timerChoices: [Int] {
        Set([1, 2, 3, 5, 10, 15, 20, 25, 30, 45, 60, 90, 120, 180, timerMinutes]).sorted()
    }

    private var canAdd: Bool {
        title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false && schedule != .weekdays([])
    }

    init(model: HabitsModel, editing habit: Habit? = nil) {
        self.model = model
        self.habit = habit
        _avoids = State(initialValue: habit?.limit != nil)
        _limit = State(initialValue: habit?.limit ?? 0)
        _title = State(initialValue: habit?.title ?? "")
        _symbol = State(initialValue: habit?.symbol ?? HabitSymbol.all[0].id)
        _timesPerDay = State(initialValue: habit?.timesPerDay ?? 1)
        _reminders = State(initialValue: (habit?.reminders ?? []).map { time in
            RemindersSection.Row(time: Calendar.current.date(bySettingHour: time.hour, minute: time.minute, second: 0, of: .now) ?? .now)
        })
        let measure = habit?.health?.measure ?? .steps
        _linksHealth = State(initialValue: habit?.health != nil)
        _healthMeasure = State(initialValue: measure)
        _healthGoal = State(initialValue: habit?.health?.goal ?? measure.defaultGoal)
        _isTimed = State(initialValue: habit?.timerMinutes != nil)
        _timerMinutes = State(initialValue: habit?.timerMinutes ?? 10)
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
                    Picker("Tipo", selection: $avoids) {
                        Text("Da fare").tag(false)
                        Text("Da evitare").tag(true)
                    }
                    .pickerStyle(.segmented)
                    .labelsHidden()
                    // Changing the kind would rewrite what the log means.
                    .disabled(habit != nil)
                    .onChange(of: avoids, dropWeekly)

                    TextField("Titolo", text: $title)
                        .onChange(of: title, limitTitle)

                    if avoids {
                        Stepper(value: $limit, in: Habit.limitRange) {
                            LabeledContent("Limite al giorno", value: limit, format: .number)
                        }
                    } else if kind != .timesPerWeek, linksHealth == false, isTimed == false {
                        // A weekly habit is done once a day: its count is the days of the week.
                        // So is one linked to Salute, done when the goal is reached, and a timed
                        // one, done when its countdown ends.
                        Stepper(value: $timesPerDay, in: Habit.timesPerDayRange) {
                            LabeledContent("Volte al giorno", value: timesPerDay, format: .number)
                        }
                    }

                    // Salute or the countdown marks it done: never both.
                    if avoids == false, linksHealth == false {
                        Toggle("A tempo", isOn: $isTimed)
                            .onChange(of: isTimed, askForNotifications)
                        if isTimed {
                            Picker("Durata", selection: $timerMinutes) {
                                ForEach(timerChoices, id: \.self) { minutes in
                                    Text(Duration.seconds(minutes * 60), format: TimerFormat.length)
                                        .tag(minutes)
                                }
                            }
                        }
                    }
                } footer: {
                    if avoids {
                        Text("Quando cedi, tieni premuta l'abitudine. Il giorno è fatto se resti entro il limite.")
                    } else if isTimed, linksHealth == false {
                        Text("Avvia il timer dall'anello: alla fine si segna da sola.")
                    }
                }

                Section("Programmazione") {
                    Picker("Programmazione", selection: $kind) {
                        Text("Ogni giorno").tag(Kind.everyDay)
                        Text("Giorni della settimana").tag(Kind.weekdays)
                        if avoids == false {
                            Text("Volte a settimana").tag(Kind.timesPerWeek)
                        }
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

                // Only a habit to do can reach a goal in Salute.
                if avoids == false, isTimed == false, model.isHealthAvailable {
                    HealthSection(isOn: $linksHealth, measure: $healthMeasure, goal: $healthGoal)
                }

                if avoids == false {
                    RemindersSection(rows: $reminders)
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

    /// An Abitudine da evitare is never weekly.
    private func dropWeekly() {
        if avoids, kind == .timesPerWeek {
            kind = .everyDay
        }
    }

    /// The end of a countdown comes as a notification: iOS asks only the first time.
    private func askForNotifications() {
        if isTimed {
            Task {
                _ = await ReminderScheduler.requestAuthorization()
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
        let times = reminders.map { row in
            let parts = Calendar.current.dateComponents([.hour, .minute], from: row.time)
            return ReminderTime(hour: parts.hour ?? 0, minute: parts.minute ?? 0)
        }
        let link = healthLink
        let minutes = isTimed && avoids == false && link == nil ? timerMinutes : nil
        if let habit {
            model.edit(habit, title: title, symbol: symbol, timesPerDay: timesPerDay, schedule: schedule, limit: avoids ? limit : nil, reminders: times, health: link, timerMinutes: minutes)
        } else {
            model.add(title: title, symbol: symbol, timesPerDay: timesPerDay, schedule: schedule, limit: avoids ? limit : nil, reminders: times, health: link, timerMinutes: minutes)
        }
        if let link {
            // Outlives the form: iOS asks for Salute over the grid, then the habit marks itself.
            Task {
                await model.connectHealth(link.measure)
            }
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
