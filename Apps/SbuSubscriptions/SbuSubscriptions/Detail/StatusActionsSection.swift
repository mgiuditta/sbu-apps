import SwiftUI

/// Pause, resume, cancel or reactivate. A paused or cancelled subscription leaves the total and its reminders,
/// and stays in the list, so nothing is lost and you can bring it back.
struct StatusActionsSection: View {
    let subscription: Subscription

    @Environment(\.modelContext) private var modelContext

    var body: some View {
        Section {
            switch subscription.status {
            case .active:
                Button("Metti in pausa") { set(.paused) }
                Button("Segna come annullato") { set(.cancelled) }
            case .paused:
                Button("Riprendi") { set(.active) }
                Button("Segna come annullato") { set(.cancelled) }
            case .cancelled:
                Button("Riattiva") { set(.active) }
            }
        } footer: {
            Text("In pausa o annullato non entra nel totale e non ti ricorda i pagamenti.")
        }
    }

    private func set(_ status: SubscriptionStatus) {
        subscription.status = status
        try? modelContext.save()
    }
}
