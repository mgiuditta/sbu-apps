import SbuKit
import SwiftUI

/// The form's reminder times. Asks for notification permission when the first one is added.
struct RemindersSection: View {
    /// One editable time; its own id keeps rows stable while times change or repeat.
    struct Row: Identifiable {
        let id = UUID()
        var time: Date
    }

    @Binding var rows: [Row]

    @State private var isDenied = false

    var body: some View {
        Section {
            ForEach($rows) { $row in
                DatePicker("Orario", selection: $row.time, displayedComponents: .hourAndMinute)
            }
            .onDelete(perform: delete)

            Button("Aggiungi promemoria", systemImage: "plus", action: add)
        } header: {
            Text("Promemoria")
        } footer: {
            if isDenied {
                Text("Attiva le notifiche di Sbu Habits nelle Impostazioni di iOS.")
            }
        }
    }

    private func add() {
        let isFirst = rows.isEmpty
        let nine = Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: .now) ?? .now
        rows.append(Row(time: rows.last.map { $0.time.addingTimeInterval(3_600) } ?? nine))
        if isFirst {
            Task {
                isDenied = await ReminderScheduler.requestAuthorization() == false
            }
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
    @State private var rows = [RemindersSection.Row(time: .now)]

    var body: some View {
        Form {
            RemindersSection(rows: $rows)
        }
        .tint(SbuTheme.accentHabits)
    }
}
