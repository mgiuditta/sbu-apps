import SbuKit
import SwiftUI

/// The Notifiche screen's Promemoria: none, automatic or custom, with the custom times below.
/// Asks for notification permission when reminders are first turned on.
struct RemindersSection: View {
    /// One editable time; its own id keeps rows stable while times change or repeat.
    struct Row: Identifiable {
        let id = UUID()
        var time: Date
    }

    @Binding var mode: ReminderMode
    @Binding var rows: [Row]

    @State private var isDenied = false

    private var showsDenied: Bool {
        mode != .off && isDenied
    }

    var body: some View {
        Section {
            Picker("Promemoria", selection: $mode) {
                ForEach(ReminderMode.allCases, id: \.self) { mode in
                    Text(mode.title)
                        .tag(mode)
                }
            }
            .pickerStyle(.inline)
            .labelsHidden()

            if mode == .custom {
                ForEach($rows) { $row in
                    DatePicker("Orario", selection: $row.time, displayedComponents: .hourAndMinute)
                }
                .onDelete(perform: delete)

                Button("Aggiungi promemoria", systemImage: "plus", action: add)
            }
        } header: {
            Text("Promemoria")
        } footer: {
            // Nothing at all when there is nothing to say: an empty footer is an unnamed element.
            if mode == .automatic || showsDenied {
                VStack(alignment: .leading, spacing: SbuTheme.space2) {
                    if mode == .automatic {
                        Text("Ti ricorda all'ora in cui di solito la fai, se oggi non è ancora fatta.")
                    }
                    if showsDenied {
                        Text("Attiva le notifiche di Sbu Habits nelle Impostazioni di iOS.")
                    }
                }
            }
        }
        .onChange(of: mode, modeChanged)
        .task {
            isDenied = await ReminderScheduler.isDenied()
        }
    }

    /// Custom times start with one row, and turning reminders on asks for permission once.
    private func modeChanged() {
        if mode == .custom && rows.isEmpty {
            add()
        } else if mode != .off {
            askForNotifications()
        }
    }

    private func add() {
        let isFirst = rows.isEmpty
        let nine = Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: .now) ?? .now
        rows.append(Row(time: rows.last.map { $0.time.addingTimeInterval(3_600) } ?? nine))
        if isFirst {
            askForNotifications()
        }
    }

    private func askForNotifications() {
        Task {
            isDenied = await ReminderScheduler.requestAuthorization() == false
        }
    }

    private func delete(at offsets: IndexSet) {
        rows.remove(atOffsets: offsets)
    }
}

#Preview("Light") {
    RemindersSectionPreview()
}

#Preview("Dark") {
    RemindersSectionPreview()
        .preferredColorScheme(.dark)
}

private struct RemindersSectionPreview: View {
    @State private var mode = ReminderMode.custom
    @State private var rows = [RemindersSection.Row(time: .now)]

    var body: some View {
        Form {
            RemindersSection(mode: $mode, rows: $rows)
        }
        .tint(SbuTheme.accentHabits)
    }
}
