import SbuKit
import SwiftUI

/// The form's link to Salute: the measure that marks the habit done by itself, listed by group
/// as Salute groups them. Its daily goal is set on the Obiettivo screen; choosing another measure
/// starts it from that measure's.
struct HealthSection: View {
    @Binding var isOn: Bool
    @Binding var measure: HealthMeasure
    @Binding var goal: Double

    var body: some View {
        Section {
            Toggle("Collega a Salute", isOn: $isOn)
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

        if isOn {
            // One list of choices in sections: each group's picker checks the measure only
            // when it is one of its own.
            ForEach(HealthMeasureGroup.allCases) { group in
                Section {
                    Picker(selection: $measure) {
                        ForEach(group.measures) { measure in
                            Text(measure.title)
                                .tag(measure)
                        }
                    } label: {
                        Text(group.title)
                    }
                    .pickerStyle(.inline)
                    .labelsHidden()
                } header: {
                    Text(group.title)
                }
            }
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
