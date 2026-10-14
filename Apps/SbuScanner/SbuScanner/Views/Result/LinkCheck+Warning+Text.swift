import SwiftUI

extension LinkCheck.Warning {
    var title: LocalizedStringResource {
        switch self {
        case .notEncrypted: "Non cifrato"
        case .lookAlike: "Lettere che imitano altre"
        case .ipAddress: "Indirizzo numerico"
        case .hiddenHost: "Indirizzo mascherato"
        case .shortener: "Link accorciato"
        }
    }

    var explanation: LocalizedStringResource {
        switch self {
        case .notEncrypted: "Il sito usa http: quello che scrivi può essere letto lungo la strada."
        case .lookAlike: "Il nome usa lettere di altri alfabeti che sembrano uguali a quelle latine."
        case .ipAddress: "Al posto del nome del sito c'è un numero: non sai di chi è."
        case .hiddenHost: "Quello che sta prima di @ è solo decorazione: il sito vero è dopo."
        case .shortener: "Il link passa da un servizio che lo accorcia: dove porta lo vedi solo dopo averlo aperto."
        }
    }
}
