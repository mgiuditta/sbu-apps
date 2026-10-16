import Foundation

extension TVClientError {
    /// One short sentence for the screen.
    var message: LocalizedStringResource {
        switch self {
        case .notPaired: "La TV non riconosce più il telefono. Collegala di nuovo."
        case .rejected: "La TV ha rifiutato. Controlla il codice o scegli Consenti sulla TV."
        case .unreachable: "La TV non risponde. Controlla che sia accesa e sulla stessa Wi-Fi."
        case .unexpectedReply: "La TV ha risposto in un modo che Sbu Remote non conosce."
        case .unsupported: "Questa TV non ha questo comando."
        case .needsPlainConfirmation: "Questa TV parla senza cifratura."
        case .localNetworkDenied: "Rete locale disattivata per Sbu Remote."
        }
    }
}
