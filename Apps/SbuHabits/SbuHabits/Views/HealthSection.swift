import SbuKit
import SwiftUI

/// The form's link to Salute: a measure and a daily goal that mark the habit done by itself.
struct HealthSection: View {
    @Binding var isOn: Bool
    @Binding var measure: HealthMeasure
    @Binding var goal: Double

    var body: some View {
        Section {
            Toggle("Collega a Salute", isOn: $isOn)

            if isOn {
                Picker("Misura", selection: $measure) {
                    ForEach(HealthMeasure.allCases) { measure in
                        Text(measure.title)
                            .tag(measure)
                    }
                }

                Stepper(value: $goal, in: measure.goalRange, step: measure.goalStep) {
                    LabeledContent("Obiettivo al giorno", value: measure.formatted(goal))
                }
            }
        } header: {
            Text("Salute")
        } footer: {
            if isOn {
                Text("Si segna da sola quando Salute arriva all'obiettivo. Se neghi l'accesso, la segni tu.")
            }
        }
        .onChange(of: measure) {
            goal = measure.defaultGoal
        }
    }
}

#Preview("Light") {
    HealthSectionPreview()
}

#Preview("Dark") {
    HealthSectionPreview()
        .preferredColorScheme(.dark)
}

private struct HealthSectionPreview: View {
    @State private var isOn = true
    @State private var measure = HealthMeasure.steps
    @State private var goal = HealthMeasure.steps.defaultGoal

    var body: some View {
        Form {
            HealthSection(isOn: $isOn, measure: $measure, goal: $goal)
        }
        .tint(SbuTheme.accentHabits)
    }
}
