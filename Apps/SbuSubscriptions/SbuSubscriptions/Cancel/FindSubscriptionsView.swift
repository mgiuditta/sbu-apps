import SbuKit
import StoreKit
import SwiftUI

/// Settings → where forgotten subscriptions hide, in a few lines each.
struct FindSubscriptionsView: View {
    @State private var isManagingAppStore = false

    var body: some View {
        List {
            Section {
                Text("Impostazioni dell'iPhone, il tuo nome in alto, poi Abbonamenti. Ci sono tutti quelli che paghi con l'App Store.")
                Button("Apri gli abbonamenti dell'App Store") { isManagingAppStore = true }
            } header: {
                Text("App Store")
            }
            Section("Estratto conto") {
                Text("Cerca gli addebiti con lo stesso importo ogni mese o ogni anno, anche piccoli. Guarda gli ultimi dodici mesi: gli annuali passano una volta sola.")
            }
            Section("PayPal") {
                Text("Nell'app PayPal: Impostazioni, Pagamenti, Gestisci pagamenti automatici.")
            }
            Section("Email") {
                Text("Cerca «ricevuta», «rinnovo» o «abbonamento» nella tua email: ogni servizio manda una ricevuta a ogni pagamento.")
            }
        }
        .navigationTitle("Dove trovare gli abbonamenti")
        .navigationBarTitleDisplayMode(.inline)
        .manageSubscriptionsSheet(isPresented: $isManagingAppStore)
    }
}

#Preview("Light") {
    NavigationStack { FindSubscriptionsView() }
}

#Preview("Dark") {
    NavigationStack { FindSubscriptionsView() }
        .preferredColorScheme(.dark)
}
