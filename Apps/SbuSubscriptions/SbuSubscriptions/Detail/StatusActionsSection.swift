import SbuKit
import SwiftUI

/// The detail's closing actions: mark it cancelled (or bring it back) as the one primary button,
/// then delete it, which asks first.
struct StatusActionsSection: View {
    let subscription: Subscription
    let delete: () -> Void

    @Environment(\.modelContext) private var modelContext

    var body: some View {
        Section {
            VStack(spacing: SbuTheme.space3) {
                if subscription.status == .cancelled {
                    SbuButton("Riattiva", action: reactivate)
                        .accessibilityIdentifier("reactivate")
                } else {
                    SbuButton("Segna come annullato", action: markCancelled)
                        .accessibilityIdentifier("markCancelled")
                }
                SbuButton("Elimina abbonamento", kind: .destructive, confirmationTitle: "Eliminare \(subscription.name)?", action: delete)
                    .accessibilityIdentifier("delete")
            }
            .listRowInsets(EdgeInsets())
            .listRowBackground(Color.clear)
        } footer: {
            if subscription.status == .cancelled {
                Text("Annullato non entra nel totale e non ti ricorda i pagamenti. Riattivalo quando vuoi.")
            }
        }
    }

    private func markCancelled() {
        subscription.setStatus(.cancelled)
        try? modelContext.save()
    }

    private func reactivate() {
        subscription.setStatus(.active)
        try? modelContext.save()
    }
}

#Preview("Light") {
    List { StatusActionsSection(subscription: .preview) {} }
        .modelContainer(.preview)
}

#Preview("Dark") {
    List { StatusActionsSection(subscription: .preview) {} }
        .modelContainer(.preview)
        .preferredColorScheme(.dark)
}
