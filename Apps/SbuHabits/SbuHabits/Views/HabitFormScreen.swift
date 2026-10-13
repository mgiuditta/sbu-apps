import SbuKit
import SwiftUI

/// The form that creates or edits a habit, as Streaks lays it out: the ring and the title as the
/// grid will show them, with "…" for the symbol; the Titolo, automatic when blank; rows for
/// Tipo, Obiettivo and Giorni, then Notifiche and Salute, each on its own screen; and the save
/// button at the bottom. The kind Da evitare is chosen once; editing never rewrites the log,
/// and offers Elimina. It lives in a navigation stack: `HabitForm`'s own when editing, Aggiungi
/// abitudine's when adding, so `close` ends the whole sheet rather than this screen.
struct HabitFormScreen: View {
    let model: HabitsModel
    /// The habit to edit, or `nil` to add a new one.
    let habit: Habit?
    /// Closes the sheet, after saving, deleting or cancelling.
    let close: () -> Void

    @State private var draft: HabitDraft
    @State private var reminders: [RemindersSection.Row]
    /// The preview ring is not scaled: it is a picture, hidden from VoiceOver.
    private let ringSize = SbuTheme.space12 * 3

    private var formTitle: LocalizedStringKey {
        habit == nil ? "Nuova abitudine" : "Modifica abitudine"
    }

    private var confirmTitle: LocalizedStringKey {
        habit == nil ? "Aggiungi abitudine" : "Salva abitudine"
    }

    private var kindChoices: [HabitKind] {
        HabitKind.choices(isNew: habit == nil, current: draft.kind, linksHealth: draft.linksHealth)
    }

    private var showsHealth: Bool {
        draft.canLinkHealth && model.isHealthAvailable
    }

    /// From today on, or from the habit's own day if it already passed.
    private var oneDayRange: PartialRangeFrom<Date> {
        let today = model.today.noon(in: .current)
        if case .oneDay(let day) = habit?.schedule {
            return min(day.noon(in: .current), today)...
        }
        return today...
    }

    /// - Parameter draft: where a new habit starts, as a Modello fills it; `habit`'s settings otherwise.
    init(model: HabitsModel, editing habit: Habit? = nil, draft: HabitDraft? = nil, close: @escaping () -> Void) {
        self.model = model
        self.habit = habit
        self.close = close
        _draft = State(initialValue: draft ?? HabitDraft(habit: habit, today: model.today))
        _reminders = State(initialValue: (habit?.reminders ?? []).map { time in
            RemindersSection.Row(time: Calendar.current.date(bySettingHour: time.hour, minute: time.minute, second: 0, of: .now) ?? .now)
        })
    }

    var body: some View {
        Form {
            Section {
                VStack(spacing: SbuTheme.space6) {
                    HabitPreview(draft: draft, ringSize: ringSize, symbolFont: SbuTheme.largeTitle) {
                        HabitSymbolButton(selection: $draft.symbol)
                    }
                    if draft.healthLink != nil {
                        HealthInfoBox()
                    }
                }
            }
            .listRowBackground(Color.clear)
            .listRowInsets(EdgeInsets())

            HabitTitleSection(title: $draft.title)

            Section {
                kindRow
                if let goal = draft.goal {
                    NavigationLink(value: HabitFormRoute.goal) {
                        HabitFormRow(title: goal.title, systemImage: goal == .duration ? "timer" : "target", value: draft.goalSummary() ?? "")
                    }
                }
                NavigationLink(value: HabitFormRoute.days) {
                    HabitFormRow(title: "Giorni", systemImage: "calendar", value: draft.daysSummary())
                }
            }
            .listRowBackground(SbuTheme.surfaceRaised)

            if draft.hasReminders || showsHealth {
                Section {
                    if draft.hasReminders {
                        NavigationLink(value: HabitFormRoute.notifications) {
                            HabitFormRow(title: "Notifiche", systemImage: "bell", value: draft.remindersSummary(times: reminders.map(\.time)))
                        }
                    }
                    if showsHealth {
                        NavigationLink(value: HabitFormRoute.health) {
                            HabitFormRow(title: "Salute", systemImage: "heart", value: draft.healthSummary())
                        }
                    }
                }
                .listRowBackground(SbuTheme.surfaceRaised)
            }

            if habit != nil {
                Section {
                    SbuButton("Elimina", kind: .destructive, action: delete)
                }
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
            }
        }
        .scrollContentBackground(.hidden)
        .background(SbuTheme.surface)
        .safeAreaInset(edge: .bottom) {
            SbuButton(confirmTitle, action: confirm)
                .disabled(draft.canSave == false)
                .padding(.horizontal, SbuTheme.space4)
                .padding(.vertical, SbuTheme.space2)
                .background(SbuTheme.surface)
        }
        .navigationDestination(for: HabitFormRoute.self, destination: screen)
        .navigationTitle(formTitle)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await askForNotifications()
        }
    }

    /// A row that opens the Tipo screen, or only says the kind when there is no other to choose.
    @ViewBuilder
    private var kindRow: some View {
        let row = HabitFormRow(title: "Tipo", systemImage: "checkmark.circle", value: draft.kindSummary())
        if kindChoices.count > 1 {
            NavigationLink(value: HabitFormRoute.kind) {
                row
            }
        } else {
            row
        }
    }

    @ViewBuilder
    private func screen(for route: HabitFormRoute) -> some View {
        switch route {
        case .kind:
            HabitKindScreen(draft: $draft, choices: kindChoices)
        case .goal:
            HabitGoalScreen(draft: $draft)
        case .days:
            HabitDaysScreen(draft: $draft, oneDayRange: oneDayRange)
        case .notifications:
            HabitNotificationsScreen(draft: $draft, reminders: $reminders)
        case .health:
            HabitHealthScreen(draft: $draft)
        }
    }

    /// A Modello or Personalizzata of the tab A tempo starts timed: the end of its countdown
    /// comes as a notification, as when Tipo turns a habit timed. iOS asks only the first time.
    private func askForNotifications() async {
        if habit == nil, draft.kind == .timed {
            _ = await ReminderScheduler.requestAuthorization()
        }
    }

    private func confirm() {
        let times: [ReminderTime] = draft.reminderMode != .custom ? [] : reminders.map { row in
            let parts = Calendar.current.dateComponents([.hour, .minute], from: row.time)
            return ReminderTime(hour: parts.hour ?? 0, minute: parts.minute ?? 0)
        }
        let title = draft.resolvedTitle()
        let schedule = draft.schedule()
        let link = draft.healthLink
        if let habit {
            model.edit(habit, title: title, symbol: draft.symbol, timesPerDay: draft.timesPerDay, schedule: schedule, limit: draft.savedLimit, reminders: times, remindsAutomatically: draft.reminderMode == .automatic, notificationStyle: draft.savedNotificationStyle, health: link, timerMinutes: draft.savedTimerMinutes)
        } else {
            model.add(title: title, symbol: draft.symbol, timesPerDay: draft.timesPerDay, schedule: schedule, limit: draft.savedLimit, reminders: times, remindsAutomatically: draft.reminderMode == .automatic, notificationStyle: draft.savedNotificationStyle, health: link, timerMinutes: draft.savedTimerMinutes)
        }
        if let link {
            // Outlives the form: iOS asks for Salute over the grid, then the habit marks itself.
            Task {
                await model.connectHealth(link.measure)
            }
        }
        close()
    }

    private func delete() {
        if let habit {
            model.delete(habit)
        }
        close()
    }
}

#Preview("Light") {
    NavigationStack {
        HabitFormScreen(model: .preview, draft: HabitTemplate.all[0].draft(today: LogicalDay(.now))) {}
    }
    .tint(SbuTheme.accentHabits)
}

#Preview("Dark") {
    NavigationStack {
        HabitFormScreen(model: .preview, draft: HabitTemplateCategory.health.customDraft(today: LogicalDay(.now))) {}
    }
    .tint(SbuTheme.accentHabits)
    .preferredColorScheme(.dark)
}
