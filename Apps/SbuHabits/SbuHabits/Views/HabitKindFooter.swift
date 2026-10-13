import SbuKit
import SwiftUI

/// What the chosen kind means, under the Tipo picker.
struct HabitKindFooter: View {
    let kind: HabitKind
    let linksHealth: Bool

    var body: some View {
        switch kind {
        case .toDo where linksHealth:
            Text("Collegata a Salute, non può essere a tempo.")
        case .toDo:
            Text("La segni tu tenendola premuta.")
        case .timed:
            Text("Avvia il timer dall'anello: alla fine si segna da sola.")
        case .toAvoid:
            Text("Quando cedi, tieni premuta l'abitudine. Il giorno è fatto se resti entro il limite.")
        }
    }
}

#Preview("Light") {
    Form {
        Section {} footer: {
            HabitKindFooter(kind: .toAvoid, linksHealth: false)
        }
    }
}

#Preview("Dark") {
    Form {
        Section {} footer: {
            HabitKindFooter(kind: .timed, linksHealth: false)
        }
    }
    .preferredColorScheme(.dark)
}
