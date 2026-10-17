import SbuKit
import SwiftUI

/// Impostazioni: the way to the order of the habits, which the grid and the Statistiche follow,
/// in the settings as Streaks has it.
struct HabitOrderSection: View {
    let model: HabitsModel

    var body: some View {
        Section {
            NavigationLink {
                HabitOrderView(model: model)
            } label: {
                Text("Ordine delle abitudini")
                    .foregroundStyle(SbuTheme.ink)
            }
            .disabled(model.habits.count < 2)
        } footer: {
            Text("La griglia e le Statistiche seguono quest'ordine.")
        }
    }
}

#Preview("Light") {
    NavigationStack {
        List {
            HabitOrderSection(model: .preview)
        }
    }
    .tint(SbuTheme.ink)
}

#Preview("Dark") {
    NavigationStack {
        List {
            HabitOrderSection(model: .preview)
        }
    }
    .tint(SbuTheme.ink)
    .preferredColorScheme(.dark)
}
