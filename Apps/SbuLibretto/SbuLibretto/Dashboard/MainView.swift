import SbuKit
import SwiftData
import SwiftUI

/// The dashboard, in the order of the original: the weighted average closed by the full stop, the
/// credits, Registra voto and Simula esame, the study plan, then the statistics.
///
/// The original's tab bar (Dashboard, Piano di studi, Università, Profilo) becomes rows here: an
/// Sbu app has one screen and Settings. Università's parameters live in Settings; Profilo is not needed.
struct MainView: View {
    let settings: CourseSettings

    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Exam.createdAt) private var exams: [Exam]
    @State private var isRegistering = false

    var body: some View {
        let transcript = Transcript(exams.map(\.record), rules: settings.rules)
        List {
            if !exams.isEmpty {
                Section {
                    AverageFigure(transcript: transcript)
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                }
                CreditsSection(transcript: transcript, settings: settings)
                Section {
                    Button(action: register) {
                        OverviewLink(title: "Registra voto", systemImage: "plus.circle")
                    }
                    .accessibilityIdentifier("registerGrade")
                    NavigationLink {
                        SimulatorView(settings: settings)
                    } label: {
                        OverviewLink(title: "Simula esame", systemImage: "chart.line.uptrend.xyaxis")
                    }
                    .accessibilityIdentifier("simulate")
                    NavigationLink {
                        StudyPlanView(settings: settings)
                    } label: {
                        OverviewLink(title: "Piano di studi", systemImage: "list.bullet.rectangle")
                    }
                    .accessibilityIdentifier("studyPlan")
                }
                .listRowBackground(SbuTheme.surfaceRaised)
                StatisticsSection(transcript: transcript, names: Dictionary(exams.map { ($0.id, $0.name) }, uniquingKeysWith: { first, _ in first }))
            }
        }
        .listStyle(.insetGrouped)
        .listSectionSpacing(.compact)
        .scrollContentBackground(.hidden)
        .overlay {
            if exams.isEmpty {
                FirstExamView(addExam: register, addSample: addSample)
            }
        }
        .sheet(isPresented: $isRegistering) {
            ExamForm(exam: nil, startsTaken: true, courseYear: exams.map(\.courseYear).max() ?? 1)
        }
    }

    private func register() {
        isRegistering = true
    }

    private func addSample() {
        SampleLibretto.insert(into: modelContext, now: .now)
    }
}

#Preview("Light") {
    NavigationStack {
        MainView(settings: LaunchMode.sample.courseSettings())
    }
    .modelContainer(.preview)
    .tint(SbuTheme.accentLibretto)
}

#Preview("Dark") {
    NavigationStack {
        MainView(settings: LaunchMode.empty.courseSettings())
    }
    .modelContainer(for: [Exam.self, Lesson.self], inMemory: true)
    .tint(SbuTheme.accentLibretto)
    .preferredColorScheme(.dark)
}
