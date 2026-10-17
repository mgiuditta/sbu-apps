import SbuKit
import SwiftData
import SwiftUI

/// The tool screen: Media ponderata and its cartiglio, the weighted average as the figure on the
/// grid, then the cards on paper: the credits, the ways into the libretto and the statistics.
///
/// The original's tab bar (Dashboard, Piano di studi, Università, Profilo) becomes rows here: an
/// Sbu app has one screen and Settings. Università's parameters live in Settings; Profilo is not needed.
struct MainView: View {
    let settings: CourseSettings

    @Environment(\.modelContext) private var modelContext
    @Environment(\.calendar) private var calendar
    @Query(sort: \Exam.createdAt) private var exams: [Exam]
    @State private var isRegistering = false
    /// An exam was saved as passed in the sheet: the Closure waits for the sheet to go, so it is seen.
    @State private var isExamPassed = false
    @State private var isClosing = false
    /// The visible height of the scroll view: on the first run the grid fills it.
    @State private var viewportHeight: CGFloat = 0

    var body: some View {
        let transcript = Transcript(exams.map(\.record), rules: settings.rules)
        let countdown = ExamCountdown(exams.map(\.planItem), now: .now, calendar: calendar)
        ScrollView {
            VStack(alignment: .leading, spacing: SbuTheme.space6) {
                figureZone(transcript)
                if !exams.isEmpty {
                    DashboardOverview(settings: settings, transcript: transcript, countdown: countdown, names: names)
                        .padding(.horizontal, SbuTheme.space4)
                        .padding(.bottom, SbuTheme.space6)
                }
            }
        }
        .scrollBounceBehavior(.basedOnSize)
        .onGeometryChange(for: CGFloat.self) { proxy in
            proxy.size.height
        } action: { height in
            viewportHeight = height
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            if !exams.isEmpty {
                SbuButton("Registra voto", action: register)
                    .accessibilityIdentifier("registerGrade")
                    .padding(.horizontal, SbuTheme.space4)
                    .padding(.vertical, SbuTheme.space2)
                    .background(SbuTheme.paper)
            }
        }
        .task(id: WidgetSnapshot(transcript: transcript, countdown: countdown)) {
            WidgetSync.publish(WidgetSnapshot(transcript: transcript, countdown: countdown))
        }
        .sheet(isPresented: $isRegistering, onDismiss: closeExam) {
            ExamForm(exam: nil, startsTaken: true, courseYear: exams.map(\.courseYear).max() ?? 1, onPassed: examPassed)
        }
    }

    /// Title, cartiglio and the figure on the grid; on the first run, the grid fills the screen.
    private func figureZone(_ transcript: Transcript) -> some View {
        VStack(alignment: .leading, spacing: SbuTheme.space6) {
            SbuScreenTitle("Media ponderata", cartiglio: cartiglio(transcript))
            Group {
                if exams.isEmpty {
                    FirstExamView(addExam: register, addSample: addSample)
                } else {
                    AverageFigure(transcript: transcript)
                }
            }
            .sbuClosure($isClosing, word: "Superato")
        }
        .padding(.horizontal, SbuTheme.space4)
        .padding(.vertical, SbuTheme.space6)
        .frame(maxWidth: .infinity, minHeight: exams.isEmpty ? viewportHeight : nil, alignment: .topLeading)
        .sbuPaper(grid: true)
    }

    /// "Sbu · Libretto · 69 CFU": the credits earned, once there is an exam.
    private func cartiglio(_ transcript: Transcript) -> String {
        // "Libretto" is the app's name in every language.
        var parts = ["Sbu", "Libretto"]
        if !exams.isEmpty {
            parts.append(String(localized: "\(transcript.earnedCredits.formatted(LibrettoFormat.credits)) CFU"))
        }
        return parts.joined(separator: " · ")
    }

    /// The exam names by id, for the chart's callout.
    private var names: [ExamRecord.ID: String] {
        Dictionary(exams.map { ($0.id, $0.name) }, uniquingKeysWith: { first, _ in first })
    }

    private func register() {
        isRegistering = true
    }

    private func examPassed() {
        isExamPassed = true
    }

    /// Once per exam saved as passed, when its sheet has gone.
    private func closeExam() {
        guard isExamPassed else { return }
        isExamPassed = false
        isClosing = true
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
    .environment(\.sbuAccent, .libretto)
    .tint(SbuTheme.ink)
}

#Preview("Dark") {
    NavigationStack {
        MainView(settings: LaunchMode.empty.courseSettings())
    }
    .modelContainer(for: [Exam.self, Lesson.self], inMemory: true)
    .environment(\.sbuAccent, .libretto)
    .tint(SbuTheme.ink)
    .preferredColorScheme(.dark)
}
