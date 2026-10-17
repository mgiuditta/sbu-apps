import SbuKit
import SwiftData
import SwiftUI

/// Prossimi appelli: the exams still to take with their countdown, soonest first; then the dates
/// gone by without a grade, and the exams with no date yet. Tap one to register its grade or move it.
struct UpcomingExamsView: View {
    @Environment(\.calendar) private var calendar
    @Query(sort: \Exam.createdAt) private var exams: [Exam]
    @State private var editing: Exam?
    @State private var isAdding = false
    /// The visible height of the screen: with no sitting the grid fills it.
    @State private var viewportHeight: CGFloat = 0

    var body: some View {
        let countdown = ExamCountdown(exams.map(\.planItem), now: .now, calendar: calendar)
        List {
            if !countdown.upcoming.isEmpty {
                Section("In arrivo") {
                    ForEach(countdown.upcoming) { sitting in
                        sittingButton(sitting)
                    }
                }
            }
            if !countdown.overdue.isEmpty {
                Section {
                    ForEach(countdown.overdue) { sitting in
                        sittingButton(sitting)
                    }
                } header: {
                    Text("Data passata")
                } footer: {
                    Text("Registra il voto, o sposta la data al prossimo appello.")
                }
            }
            if !countdown.undated.isEmpty {
                Section("Senza data") {
                    ForEach(countdown.undated) { item in
                        Button {
                            edit(item.id)
                        } label: {
                            ExamRow(item: item, isExcluded: false)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(SbuTheme.paper)
        .navigationTitle("Prossimi appelli")
        .navigationBarTitleDisplayMode(.inline)
        .overlay {
            if countdown.isEmpty {
                ScrollView {
                    SbuEmpty(sentence: "Aggiungi un esame da sostenere con la data dell'appello: qui vedi quanti giorni mancano.") {
                        SbuButton("Aggiungi esame", action: add)
                            .accessibilityIdentifier("addPlannedExam")
                    }
                    .padding(.horizontal, SbuTheme.space4)
                    .padding(.vertical, SbuTheme.space6)
                    .frame(maxWidth: .infinity, minHeight: viewportHeight, alignment: .topLeading)
                    .sbuPaper(grid: true)
                }
                .scrollBounceBehavior(.basedOnSize)
                .onGeometryChange(for: CGFloat.self) { proxy in
                    proxy.size.height
                } action: { height in
                    viewportHeight = height
                }
            }
        }
        .sheet(item: $editing) { exam in
            ExamForm(exam: exam, startsTaken: false, courseYear: exam.courseYear)
        }
        .sheet(isPresented: $isAdding) {
            ExamForm(exam: nil, startsTaken: false, courseYear: exams.map(\.courseYear).max() ?? 1)
        }
    }

    private func sittingButton(_ sitting: ExamCountdown.Sitting) -> some View {
        Button {
            edit(sitting.id)
        } label: {
            SittingRow(sitting: sitting)
        }
        .buttonStyle(.plain)
    }

    private func add() {
        isAdding = true
    }

    private func edit(_ id: UUID) {
        editing = exams.first { $0.id == id }
    }
}

#Preview("Light") {
    NavigationStack {
        UpcomingExamsView()
    }
    .modelContainer(.preview)
    .tint(SbuTheme.ink)
}

#Preview("Dark") {
    NavigationStack {
        UpcomingExamsView()
    }
    .modelContainer(for: [Exam.self, Lesson.self], inMemory: true)
    .environment(\.sbuAccent, .libretto)
    .tint(SbuTheme.ink)
    .preferredColorScheme(.dark)
}
