import SwiftUI

/// Pause or resume. A paused subscription leaves the total and its reminders, and stays in the list.
struct PauseSection: View {
    let subscription: Subscription

    @Environment(\.modelContext) private var modelContext

    var body: some View {
        if subscription.status != .cancelled {
            Section {
                if subscription.status == .paused {
                    Button("Riprendi", action: resume)
                } else {
                    Button("Metti in pausa", action: pause)
                }
            } footer: {
                Text("In pausa o annullato non entra nel totale e non ti ricorda i pagamenti.")
            }
        }
    }

    private func pause() {
        subscription.setStatus(.paused)
        try? modelContext.save()
    }

    private func resume() {
        subscription.setStatus(.active)
        try? modelContext.save()
    }
}

#Preview("Light") {
    List { PauseSection(subscription: .preview) }
        .modelContainer(.preview)
}

#Preview("Dark") {
    List { PauseSection(subscription: .preview) }
        .modelContainer(.preview)
        .preferredColorScheme(.dark)
}
