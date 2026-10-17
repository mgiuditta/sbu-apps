import SbuKit
import SwiftData
import SwiftUI

/// Add or edit a lesson: course, room, weekday, and its times. The pickers show the phone's clock;
/// the times are stored as minutes, so they never shift by twelve hours.
struct LessonForm: View {
    let lesson: Lesson?

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(\.calendar) private var calendar
    @Query private var lessons: [Lesson]
    @State private var draft: LessonDraft

    init(lesson: Lesson?, weekday: Int) {
        self.lesson = lesson
        _draft = State(initialValue: lesson.map(LessonDraft.init(lesson:)) ?? LessonDraft(weekday: weekday))
    }

    var body: some View {
        let overlaps = draft.overlaps(id: lesson?.id ?? UUID(), among: lessons.map(\.slot))
        NavigationStack {
            Form {
                Section {
                    TextField("Corso", text: $draft.title)
                        .textInputAutocapitalization(.sentences)
                        .accessibilityIdentifier("lessonTitle")
                    TextField("Aula", text: $draft.room, prompt: Text("Facoltativa"))
                        .accessibilityIdentifier("lessonRoom")
                }
                Section {
                    Picker("Giorno", selection: $draft.weekday) {
                        ForEach(LessonSlot.weekdays(calendar: calendar), id: \.self) { weekday in
                            Text(verbatim: calendar.standaloneWeekdaySymbols[weekday - 1].capitalized).tag(weekday)
                        }
                    }
                    DatePicker("Dalle", selection: time(\.start), displayedComponents: .hourAndMinute)
                        .accessibilityIdentifier("lessonStart")
                    DatePicker("Alle", selection: time(\.end), displayedComponents: .hourAndMinute)
                        .accessibilityIdentifier("lessonEnd")
                } footer: {
                    LessonFormFooter(problem: draft.problem, overlaps: overlaps)
                }
                if lesson != nil {
                    Section {
                        SbuButton("Elimina lezione", kind: .destructive, confirmationTitle: "Eliminare questa lezione?", action: delete)
                    }
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                }
            }
            .scrollContentBackground(.hidden)
            .background(SbuTheme.paper)
            .navigationTitle("Lezione")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annulla", action: close)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Salva", action: save)
                        .disabled(draft.problem != nil)
                        .accessibilityIdentifier("saveLesson")
                }
            }
        }
    }

    /// A time of the draft as the date the picker needs, today at that time.
    private func time(_ keyPath: WritableKeyPath<LessonDraft, ClockTime>) -> Binding<Date> {
        Binding {
            draft[keyPath: keyPath].date(on: .now, calendar: calendar)
        } set: {
            draft[keyPath: keyPath] = ClockTime($0, calendar: calendar)
        }
    }

    private func close() {
        dismiss()
    }

    private func save() {
        guard draft.problem == nil else { return }
        let target = lesson ?? Lesson(title: "", weekday: draft.weekday, startMinutes: 0, endMinutes: 0)
        draft.apply(to: target)
        if lesson == nil { modelContext.insert(target) }
        try? modelContext.save()
        dismiss()
    }

    private func delete() {
        guard let lesson else { return }
        modelContext.delete(lesson)
        try? modelContext.save()
        dismiss()
    }
}

#Preview("Light") {
    LessonForm(lesson: nil, weekday: 2)
        .modelContainer(.preview)
        .tint(SbuTheme.ink)
}

#Preview("Dark") {
    LessonForm(lesson: nil, weekday: 4)
        .modelContainer(.preview)
        .tint(SbuTheme.ink)
        .preferredColorScheme(.dark)
}
