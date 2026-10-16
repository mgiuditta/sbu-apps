import SbuKit
import SwiftData
import SwiftUI

/// Calendario lezioni, as in the original: the days of the week across the top, today first
/// selected, then the lessons of that day from the earliest. Times always in 24 hours.
struct TimetableView: View {
    @Environment(\.calendar) private var calendar
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Lesson.startMinutes) private var lessons: [Lesson]
    @State private var weekday: Int
    @State private var editing: Lesson?
    @State private var isAdding = false
    @State private var pendingDelete: Lesson?

    init(today: Date = .now, calendar: Calendar = .current) {
        _weekday = State(initialValue: calendar.component(.weekday, from: today))
    }

    var body: some View {
        let slots = lessons.map(\.slot)
        let day = LessonSlot.day(weekday, in: slots)
        List {
            Section {
                WeekdayPicker(selection: $weekday, slots: slots)
            }
            .listRowInsets(EdgeInsets(top: SbuTheme.space1, leading: 0, bottom: SbuTheme.space1, trailing: 0))
            .listRowBackground(Color.clear)
            Section {
                ForEach(day) { slot in
                    Button {
                        edit(slot.id)
                    } label: {
                        LessonRow(slot: slot)
                    }
                    .buttonStyle(.plain)
                    .swipeActions {
                        Button("Elimina", systemImage: "trash", role: .destructive) { askDelete(slot.id) }
                    }
                    .accessibilityAction(named: Text("Elimina")) { askDelete(slot.id) }
                }
                if day.isEmpty {
                    Text("Nessuna lezione in questo giorno.")
                        .font(SbuTheme.body)
                        .foregroundStyle(SbuTheme.inkMuted)
                }
            } header: {
                Text(verbatim: calendar.standaloneWeekdaySymbols[weekday - 1].capitalized)
            }
            .listRowBackground(SbuTheme.surfaceRaised)
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(SbuTheme.surface)
        .navigationTitle("Orario lezioni")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Aggiungi lezione", systemImage: "plus", action: add)
                    .accessibilityIdentifier("addLesson")
            }
        }
        .sheet(item: $editing) { lesson in
            LessonForm(lesson: lesson, weekday: lesson.weekday)
        }
        .sheet(isPresented: $isAdding) {
            LessonForm(lesson: nil, weekday: weekday)
        }
        .confirmationDialog("Eliminare questa lezione?", isPresented: isConfirmingDelete, titleVisibility: .visible, presenting: pendingDelete) { lesson in
            Button("Elimina", role: .destructive) { delete(lesson) }
        }
    }

    private var isConfirmingDelete: Binding<Bool> {
        Binding { pendingDelete != nil } set: { if !$0 { pendingDelete = nil } }
    }

    private func edit(_ id: UUID) {
        editing = lessons.first { $0.id == id }
    }

    private func add() {
        isAdding = true
    }

    private func askDelete(_ id: UUID) {
        pendingDelete = lessons.first { $0.id == id }
    }

    private func delete(_ lesson: Lesson) {
        modelContext.delete(lesson)
        try? modelContext.save()
        pendingDelete = nil
    }
}

#Preview("Light") {
    NavigationStack {
        TimetableView()
    }
    .modelContainer(.preview)
    .tint(SbuTheme.accentLibretto)
}

#Preview("Dark") {
    NavigationStack {
        TimetableView()
    }
    .modelContainer(for: [Exam.self, Lesson.self], inMemory: true)
    .tint(SbuTheme.accentLibretto)
    .preferredColorScheme(.dark)
}
