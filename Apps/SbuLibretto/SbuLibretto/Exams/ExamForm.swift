import SbuKit
import SwiftData
import SwiftUI

/// Add or edit an exam: name and credits, with a grade or as an idoneità, taken or still to take.
struct ExamForm: View {
    private enum Field: Hashable {
        case name
    }

    let exam: Exam?
    /// Called once when the save makes the exam taken: passed, with its grade or as an idoneità.
    let onPassed: () -> Void

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(\.locale) private var locale
    @Environment(\.calendar) private var calendar
    @Query private var exams: [Exam]
    @State private var draft: ExamDraft
    @FocusState private var focused: Field?
    @FocusState private var isEditingCredits: Bool

    private var problem: ExamDraft.Problem? {
        draft.problem(locale: locale, now: .now, calendar: calendar)
    }

    /// Another exam in the libretto already has this name: a hint, not a block, as a course can repeat.
    private var isDuplicate: Bool {
        let name = draft.trimmedName
        return !name.isEmpty && exams.contains { $0.id != exam?.id && $0.name.localizedCaseInsensitiveCompare(name) == .orderedSame }
    }

    init(exam: Exam?, startsTaken: Bool, courseYear: Int, onPassed: @escaping () -> Void = {}) {
        self.exam = exam
        self.onPassed = onPassed
        if let exam {
            _draft = State(initialValue: ExamDraft(exam: exam, now: .now, locale: .current))
        } else {
            var draft = ExamDraft(isTaken: startsTaken, now: .now)
            draft.courseYear = min(max(courseYear, ExamDraft.courseYears.lowerBound), ExamDraft.courseYears.upperBound)
            _draft = State(initialValue: draft)
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Nome dell'esame", text: $draft.name)
                        .textInputAutocapitalization(.sentences)
                        .focused($focused, equals: .name)
                        .accessibilityIdentifier("examName")
                    NumberField(title: "Crediti", text: $draft.creditsText, unit: "CFU", prompt: "6", identifier: "credits", focus: $isEditingCredits)
                    // The value in the label: a LabeledContent inside a Stepper hid it from VoiceOver.
                    Stepper(value: $draft.courseYear, in: ExamDraft.courseYears) {
                        Text("Anno di corso: \(draft.courseYear)°")
                            .monospacedDigit()
                    }
                    .accessibilityIdentifier("courseYear")
                } footer: {
                    ExamFormFooter(problem: problem, isDuplicate: isDuplicate)
                }
                Section {
                    Picker("Tipo", selection: $draft.kind) {
                        Text("Con voto").tag(ExamKind.graded)
                        Text("Idoneità").tag(ExamKind.passFail)
                    }
                    .pickerStyle(.segmented)
                    .accessibilityIdentifier("kind")
                    Toggle(draft.kind == .graded ? "Sostenuto" : "Superato", isOn: $draft.isTaken)
                        .accessibilityIdentifier("isTaken")
                } footer: {
                    Text(draft.kind == .graded
                         ? "Se non l'hai ancora sostenuto, resta tra gli esami da sostenere e non entra nella media."
                         : "Un'idoneità conta nei CFU, non nella media.")
                }
                if draft.kind == .graded && draft.isTaken {
                    GradeSection(mark: $draft.mark, cumLaude: $draft.cumLaude)
                }
                ExamDateSection(isTaken: draft.isTaken, date: $draft.date, hasDate: $draft.hasDate)
                if exam != nil {
                    Section {
                        SbuButton("Elimina esame", kind: .destructive, confirmationTitle: "Eliminare questo esame?", action: delete)
                            .accessibilityIdentifier("deleteExam")
                    }
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                }
            }
            .scrollContentBackground(.hidden)
            .scrollDismissesKeyboard(.interactively)
            .background(SbuTheme.paper)
            // One word: between Annulla and Salva a longer title has no room at larger text.
            .navigationTitle(exam == nil ? "Esame" : "Modifica")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annulla", action: close)
                }
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    // The decimal keypad has no return key.
                    Button("Fine", action: endEditing)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Salva", action: save)
                        .disabled(problem != nil)
                        .accessibilityIdentifier("saveExam")
                }
            }
            .onAppear(perform: focusName)
        }
    }

    private func focusName() {
        if exam == nil { focused = .name }
    }

    private func endEditing() {
        focused = nil
        isEditingCredits = false
    }

    private func close() {
        dismiss()
    }

    private func save() {
        guard problem == nil else { return }
        // Passed now, not before: editing an exam already passed does not close it again.
        let wasPassed = exam?.result.isDone ?? false
        let target = exam ?? Exam(name: "", credits: 0, courseYear: draft.courseYear, kind: draft.kind, date: nil)
        draft.apply(to: target, locale: locale)
        if exam == nil { modelContext.insert(target) }
        try? modelContext.save()
        if draft.isTaken && !wasPassed { onPassed() }
        dismiss()
    }

    private func delete() {
        guard let exam else { return }
        modelContext.delete(exam)
        try? modelContext.save()
        dismiss()
    }
}

#Preview("Light") {
    ExamForm(exam: nil, startsTaken: true, courseYear: 2)
        .modelContainer(.preview)
        .tint(SbuTheme.ink)
}

#Preview("Dark") {
    ExamForm(exam: nil, startsTaken: false, courseYear: 1)
        .modelContainer(.preview)
        .tint(SbuTheme.ink)
        .preferredColorScheme(.dark)
}
