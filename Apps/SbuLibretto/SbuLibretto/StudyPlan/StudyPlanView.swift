import SbuKit
import SwiftData
import SwiftUI

/// Every exam of the course, by year: the summary, the filters and the order, then the exams.
/// Tap one to edit it or to register its grade, swipe to delete.
struct StudyPlanView: View {
    let settings: CourseSettings

    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Exam.createdAt) private var exams: [Exam]
    @State private var query = PlanQuery()
    @State private var editing: Exam?
    @State private var isAdding = false
    @State private var pendingDelete: Exam?

    var body: some View {
        let transcript = Transcript(exams.map(\.record), rules: settings.rules)
        let items = exams.map(\.planItem)
        let groups = query.groups(items)
        List {
            PlanSummarySection(transcript: transcript)
            PlanControls(query: $query)
            ForEach(groups) { group in
                Section {
                    ForEach(group.items) { item in
                        Button {
                            edit(item.id)
                        } label: {
                            ExamRow(item: item, isExcluded: transcript.excludedIDs.contains(item.id))
                        }
                        .buttonStyle(.plain)
                        .swipeActions {
                            Button("Elimina", systemImage: "trash", role: .destructive) { askDelete(item.id) }
                        }
                        .accessibilityAction(named: Text("Elimina")) { askDelete(item.id) }
                    }
                } header: {
                    Text("\(group.courseYear)° anno")
                }
            }
            if groups.isEmpty {
                // In the list, under the summary and the filters that may have emptied it.
                Section {
                    ContentUnavailableView {
                        Label(exams.isEmpty ? "Nessun esame" : "Nessun esame qui", systemImage: "list.bullet.rectangle")
                    } description: {
                        Text(exams.isEmpty
                             ? "Aggiungi gli esami del tuo piano, anche quelli da sostenere."
                             : "Cambia filtro per vedere gli altri esami.")
                    }
                }
                .listRowBackground(Color.clear)
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(SbuTheme.surface)
        .navigationTitle("Piano di studi")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                YearMenu(selection: $query.courseYear, years: PlanQuery.courseYears(in: items))
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button("Aggiungi esame", systemImage: "plus", action: add)
                    .accessibilityIdentifier("addExam")
            }
        }
        .sheet(item: $editing) { exam in
            ExamForm(exam: exam, startsTaken: true, courseYear: exam.courseYear)
        }
        .sheet(isPresented: $isAdding) {
            ExamForm(exam: nil, startsTaken: false, courseYear: query.courseYear ?? exams.map(\.courseYear).max() ?? 1)
        }
        .confirmationDialog("Eliminare questo esame?", isPresented: isConfirmingDelete, titleVisibility: .visible, presenting: pendingDelete) { exam in
            Button("Elimina", role: .destructive) { delete(exam) }
        } message: { exam in
            Text("\(exam.name) esce dal libretto e dalla media.")
        }
    }

    private var isConfirmingDelete: Binding<Bool> {
        Binding { pendingDelete != nil } set: { if !$0 { pendingDelete = nil } }
    }

    private func exam(_ id: UUID) -> Exam? {
        exams.first { $0.id == id }
    }

    private func edit(_ id: UUID) {
        editing = exam(id)
    }

    private func add() {
        isAdding = true
    }

    private func askDelete(_ id: UUID) {
        pendingDelete = exam(id)
    }

    private func delete(_ exam: Exam) {
        modelContext.delete(exam)
        try? modelContext.save()
        pendingDelete = nil
    }
}

#Preview("Light") {
    NavigationStack {
        StudyPlanView(settings: LaunchMode.sample.courseSettings())
    }
    .modelContainer(.preview)
    .tint(SbuTheme.accentLibretto)
}

#Preview("Dark") {
    NavigationStack {
        StudyPlanView(settings: LaunchMode.empty.courseSettings())
    }
    .modelContainer(for: [Exam.self, Lesson.self], inMemory: true)
    .tint(SbuTheme.accentLibretto)
    .preferredColorScheme(.dark)
}
