import StoreKit
import SwiftUI

/// Where to cancel: the service's own site in Safari, or iOS's sheet of App Store subscriptions.
/// Back in the app, it asks whether you cancelled, so the list matches what you pay.
struct CancelHelpSection: View {
    let subscription: Subscription

    @Environment(\.modelContext) private var modelContext
    @Environment(\.openURL) private var openURL
    @Environment(\.scenePhase) private var scenePhase
    @State private var isManagingAppStore = false
    @State private var awaitsAnswer = false
    @State private var isAsking = false

    var body: some View {
        if subscription.status != .cancelled {
            Section {
                if let url = subscription.url, WebPage.isWebPage(url) {
                    Button("Apri \(url.host() ?? url.absoluteString)") {
                        awaitsAnswer = true
                        openURL(url)
                    }
                }
                Button("Abbonamenti dell'App Store") { isManagingAppStore = true }
            } header: {
                Text("Come annullare")
            } footer: {
                Text(subscription.url == nil
                     ? "Se lo paghi con l'App Store lo annulli qui. Altrimenti aggiungi il sito del servizio con Modifica."
                     : "Annulli sul sito del servizio, o qui se lo paghi con l'App Store.")
            }
            .manageSubscriptionsSheet(isPresented: $isManagingAppStore)
            .onChange(of: isManagingAppStore) { _, isOpen in
                if !isOpen { isAsking = true }
            }
            .onChange(of: scenePhase) { _, phase in
                if phase == .active, awaitsAnswer {
                    awaitsAnswer = false
                    isAsking = true
                }
            }
            .confirmationDialog("Hai annullato \(subscription.name)?", isPresented: $isAsking, titleVisibility: .visible) {
                Button("Segna come annullato", action: markCancelled)
                Button("Non ancora", role: .cancel) {}
            } message: {
                Text("Esce dal totale e dai promemoria. Puoi riattivarlo quando vuoi.")
            }
        }
    }

    private func markCancelled() {
        subscription.status = .cancelled
        try? modelContext.save()
    }
}
