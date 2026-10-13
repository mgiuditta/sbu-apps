import SbuKit
import SwiftUI

/// The form's Salute screen: the link and its measure. The goal is on the Obiettivo screen.
struct HabitHealthScreen: View {
    @Binding var draft: HabitDraft

    var body: some View {
        Form {
            HealthSection(isOn: $draft.linksHealth, measure: $draft.healthMeasure, goal: $draft.healthGoal)
        }
        .scrollContentBackground(.hidden)
        .background(SbuTheme.surface)
        .navigationTitle("Salute")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview("Light") {
    HabitHealthScreenPreview()
}

#Preview("Dark") {
    HabitHealthScreenPreview()
        .preferredColorScheme(.dark)
}

private struct HabitHealthScreenPreview: View {
    @State private var draft: HabitDraft = {
        var draft = HabitDraft(habit: nil, today: LogicalDay(.now))
        draft.linksHealth = true
        return draft
    }()

    var body: some View {
        NavigationStack {
            HabitHealthScreen(draft: $draft)
        }
        .tint(SbuTheme.accentHabits)
    }
}
