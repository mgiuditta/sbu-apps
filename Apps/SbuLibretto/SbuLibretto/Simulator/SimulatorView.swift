import SbuKit
import SwiftData
import SwiftUI

/// Simulazione media, as in the original: the current average, the credits of the next exam, and
/// for each grade from 30 cum laude down the new average, how it changes, and the base. Then the
/// grade a target average needs.
struct SimulatorView: View {
    let settings: CourseSettings

    @Query private var exams: [Exam]
    @State private var credits = 6
    @State private var targetText = ""

    var body: some View {
        let records = exams.map(\.record)
        let transcript = Transcript(records, rules: settings.rules)
        let simulation = Simulation(records, rules: settings.rules, credits: Double(credits))
        List {
            Section {
                // The one figure of the screen, on the paper behind the list, not in a row's card.
                CurrentAverage(transcript: transcript)
                    .listRowInsets(EdgeInsets(top: SbuTheme.space2, leading: SbuTheme.space4, bottom: SbuTheme.space2, trailing: SbuTheme.space4))
                    .listRowBackground(Color.clear)
            }
            Section("Prossimo esame") {
                // The value in the label: a LabeledContent inside a Stepper hid it from VoiceOver.
                Stepper(value: $credits, in: 1...30) {
                    Text("Crediti: \(credits) CFU")
                        .monospacedDigit()
                }
                .accessibilityIdentifier("nextCredits")
            }
            // Above the table, not under it: the answer stays in sight while the keypad is up.
            TargetSection(simulation: simulation, targetText: $targetText)
            Section {
                ForEach(simulation.rows) { row in
                    ScenarioRow(row: row)
                }
            } header: {
                Text("Scenari futuri")
            } footer: {
                Text("Proiezione con \(credits) CFU in più, con le regole del tuo corso.")
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(SbuTheme.paper)
        .scrollDismissesKeyboard(.interactively)
        .navigationTitle("Simulazione media")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview("Light") {
    NavigationStack {
        SimulatorView(settings: LaunchMode.sample.courseSettings())
    }
    .modelContainer(.preview)
    .environment(\.sbuAccent, .libretto)
    .tint(SbuTheme.ink)
}

#Preview("Dark") {
    NavigationStack {
        SimulatorView(settings: LaunchMode.empty.courseSettings())
    }
    .modelContainer(for: [Exam.self, Lesson.self], inMemory: true)
    .tint(SbuTheme.ink)
    .preferredColorScheme(.dark)
}
