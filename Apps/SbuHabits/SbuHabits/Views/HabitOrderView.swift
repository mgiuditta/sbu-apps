import SbuKit
import SwiftUI

/// Impostazioni → Ordine delle abitudini: every habit, reordered by dragging. The grid and the
/// Statistiche follow the same order.
struct HabitOrderView: View {
    let model: HabitsModel

    var body: some View {
        List {
            Section {
                ForEach(model.habits) { habit in
                    Label {
                        Text(habit.title)
                            .foregroundStyle(SbuTheme.ink)
                    } icon: {
                        Image(systemName: habit.symbol)
                            .fontWeight(.medium)
                            .imageScale(.medium)
                    }
                }
                .onMove(perform: model.move)
                .listRowBackground(SbuTheme.surfaceRaised)
            } footer: {
                Text("Trascina un'abitudine per spostarla.")
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(SbuTheme.surface)
        // Always in edit mode: the only thing to do here is move.
        .environment(\.editMode, .constant(.active))
        .navigationTitle("Ordine delle abitudini")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview("Light") {
    NavigationStack {
        HabitOrderView(model: .preview)
    }
    .tint(SbuTheme.accentHabits)
}

#Preview("Dark") {
    NavigationStack {
        HabitOrderView(model: .preview)
    }
    .tint(SbuTheme.accentHabits)
    .preferredColorScheme(.dark)
}
