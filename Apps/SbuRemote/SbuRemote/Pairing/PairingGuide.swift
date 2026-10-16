import Foundation

/// What the user will see on the TV while pairing, and the setting the TV needs, per brand.
nonisolated enum PairingGuide {
    static func onTheTV(_ brand: TVBrand) -> LocalizedStringResource {
        switch brand {
        case .samsung: "Sulla TV compare una richiesta di accesso: scegli Consenti."
        case .lg: "Sulla TV compare una richiesta di collegamento: scegli Accetta."
        case .androidTV: "Sulla TV compare un codice di 6 caratteri: scrivilo qui."
        case .sony: "Sulla TV compare un PIN di 4 cifre: scrivilo qui."
        }
    }

    static func setting(_ brand: TVBrand) -> LocalizedStringResource {
        switch brand {
        case .samsung:
            "Se la TV chiede il permesso a ogni avvio, imposta Impostazioni › Generali › Gestione dispositivi esterni › Gestione connessione dispositivi › Notifica di accesso › Solo la prima volta."
        case .lg:
            "Attiva LG Connect Apps in Impostazioni › Rete. Sui modelli recenti si chiama Accensione TV mobile, in Impostazioni › Generali › Dispositivi."
        case .androidTV:
            "Non serve attivare nulla: basta che la TV sia accesa."
        case .sony:
            "Attiva Impostazioni › Rete › Configurazione rete domestica › Controllo IP, con Autenticazione Normale e chiave precondivisa, e Avvio remoto."
        }
    }
}
