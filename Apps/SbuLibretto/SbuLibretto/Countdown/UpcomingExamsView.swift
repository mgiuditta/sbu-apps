import SbuKit
import SwiftData
import SwiftUI

/// Prossimi appelli: the exams still to take with their countdown, soonest first; then the dates
/// gone by without a grade, and the exams with no date yet. Tap one to register its grade or move it.
struct UpcomingExamsView: View {
    @Environment(\.calendar) private var calendar
    @Query(sort: \Exam.createdAt) private var exams: [Exam]
    @State private var editing: Exam?

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
        .background(SbuTheme.surface)
        .navigationTitle("Prossimi appelli")
        .navigationBarTitleDisplayMode(.inline)
        .overlay {
            if countdown.isEmpty {
                ContentUnavailableView {
                    Label("Nessun appello", systemImage: "calendar")
                } description: {
                    Text("Aggiungi un esame da sostenere con la data dell'appello: qui vedi quanti giorni mancano.")
                }
            }
        }
        .sheet(item: $editing) { exam in
            ExamForm(exam: exam, startsTaken: false, courseYear: exam.courseYear)
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

    private func edit(_ id: UUID) {
        editing = exams.first { $0.id == id }
    }
}

#Preview("Light") {
    NavigationStack {
        UpcomingExamsView()
    }
    .modelContainer(.preview)
    .tint(SbuTheme.accentLibretto)
}

#Preview("Dark") {
    NavigationStack {
        UpcomingExamsView()
    }
    .modelContainer(for: [Exam.self, Lesson.self], inMemory: true)
    .tint(SbuTheme.accentLibretto)
    .preferredColorScheme(.dark)
}
