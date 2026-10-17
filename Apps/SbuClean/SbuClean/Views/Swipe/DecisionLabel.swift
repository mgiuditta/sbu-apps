import SbuKit
import SwiftUI

/// The word that appears on a card while it is dragged: Tieni in ink, Elimina in danger,
/// each with its symbol.
struct DecisionLabel: View {
    let decision: SwipeDecision

    var body: some View {
        Group {
            if decision == .trash {
                Label("Elimina", systemImage: "trash")
                    .foregroundStyle(SbuTheme.danger)
            } else {
                Label("Tieni", systemImage: "checkmark")
                    .foregroundStyle(SbuTheme.ink)
            }
        }
        .font(SbuTheme.title2)
        .padding(.horizontal, SbuTheme.space3)
        .padding(.vertical, SbuTheme.space2)
        .background(SbuTheme.paper, in: .rect(cornerRadius: SbuTheme.radiusCard))
        .padding(SbuTheme.space4)
        .accessibilityHidden(true)
    }
}

#Preview("Light") {
    VStack {
        DecisionLabel(decision: .keep)
        DecisionLabel(decision: .trash)
    }
    .background(SbuTheme.surfaceSunken)
    .environment(\.sbuAccent, .clean)
}

#Preview("Dark") {
    VStack {
        DecisionLabel(decision: .keep)
        DecisionLabel(decision: .trash)
    }
    .background(SbuTheme.surfaceSunken)
    .environment(\.sbuAccent, .clean)
    .preferredColorScheme(.dark)
}
