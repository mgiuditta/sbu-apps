import SbuKit
import SwiftUI

/// The form's goal screen, as the kind asks: times per day, the Limite, the Durata of the
/// countdown, or the daily goal in Salute.
struct HabitGoalScreen: View {
    @Binding var draft: HabitDraft

    var body: some View {
        Form {
            // One background for whichever section the kind asks for.
            Group {
                switch draft.goal {
                case .timesPerDay:
                    Section {
                        Stepper(value: $draft.timesPerDay, in: Habit.timesPerDayRange) {
                            LabeledContent("Volte al giorno", value: draft.timesPerDay, format: .number)
                        }
                    } footer: {
                        Text("Ogni volta che la tieni premuta riempie un tratto dell'anello.")
                    }
                case .limit:
                    Section {
                        Stepper(value: $draft.limit, in: Habit.limitRange) {
                            LabeledContent("Limite al giorno", value: draft.limit, format: .number)
                        }
                    } footer: {
                        Text("Quando cedi, tieni premuta l'abitudine. Il giorno è fatto se resti entro il limite.")
                    }
                case .duration:
                    Section {
                        Picker("Durata", selection: $draft.timerMinutes) {
                            ForEach(draft.durationChoices, id: \.self) { minutes in
                                Text(Duration.seconds(minutes * 60), format: TimerFormat.length)
                                    .tag(minutes)
                            }
                        }
                        .pickerStyle(.inline)
                        // The screen's title already says Durata, as Tipo and Giorni do.
                        .labelsHidden()
                    } footer: {
                        Text("Avvia il timer dall'anello: alla fine si segna da sola.")
                    }
                case .health:
                    Section {
                        Stepper(value: $draft.healthGoal, in: draft.healthMeasure.goalRange, step: draft.healthMeasure.goalStep) {
                            LabeledContent("Obiettivo al giorno", value: draft.healthMeasure.formatted(draft.healthGoal))
                        }
                    } header: {
                        Text(draft.healthMeasure.title)
                    }
                case nil:
                    EmptyView()
                }
            }
            .listRowBackground(SbuTheme.surfaceRaised)
        }
        .scrollContentBackground(.hidden)
        .background(SbuTheme.surface)
        .navigationTitle(Text(draft.goal?.title ?? "Obiettivo"))
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview("Light") {
    HabitGoalScreenPreview()
}

#Preview("Dark") {
    HabitGoalScreenPreview(kind: .timed)
        .preferredColorScheme(.dark)
}

private struct HabitGoalScreenPreview: View {
    @State private var draft: HabitDraft

    init(kind: HabitKind = .toDo) {
        var draft = HabitDraft(habit: nil, today: LogicalDay(.now))
        draft.kind = kind
        _draft = State(initialValue: draft)
    }

    var body: some View {
        NavigationStack {
            HabitGoalScreen(draft: $draft)
        }
        .tint(SbuTheme.accentHabits)
    }
}
