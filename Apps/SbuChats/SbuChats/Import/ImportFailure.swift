import Foundation

/// Why a file didn't become a chat, in words the import error screen can show.
nonisolated enum ImportFailure: Error, Equatable, Sendable {
    /// The file can't be opened or read.
    case unreadableFile
    /// A `.zip` that isn't a ZIP, is cut short, or is encrypted.
    case damagedArchive
    /// A `.zip` without a chat text inside.
    case noChatInArchive
    /// A file type other than `.txt` or `.zip`.
    case unsupportedFile(fileExtension: String)
    /// No line starts like a message; carries the first line found.
    case unrecognizedFormat(firstLine: String)
    /// Lines look like messages but their dates read no way; carries one of them.
    case unreadableDates(sampleLine: String)
    /// The file is empty, or only has system lines.
    case noMessages
    /// More text than any export holds, or a ZIP that inflates far beyond its size.
    case tooLarge
    /// A line or a message longer than any message can be: a file without line breaks.
    case lineTooLong

    /// What went wrong, as a title.
    var title: LocalizedStringResource {
        switch self {
        case .unreadableFile: "Il file non si apre"
        case .damagedArchive: "Lo ZIP è danneggiato"
        case .noChatInArchive: "Nello ZIP non c'è una chat"
        case .unsupportedFile: "Questo file non è una chat"
        case .unrecognizedFormat: "Non riconosco il formato"
        case .unreadableDates: "Non riesco a leggere le date"
        case .noMessages: "La chat è vuota"
        case .tooLarge: "Il file è troppo grande"
        case .lineTooLong: "Il file non va a capo"
        }
    }

    /// What was found and what to do.
    var explanation: LocalizedStringResource {
        switch self {
        case .unreadableFile:
            "Sbu Chats non riesce a leggere il file. Esporta di nuovo la chat e condividila con Sbu Chats."
        case .damagedArchive:
            "Lo ZIP si è interrotto o è protetto da password. Esporta di nuovo la chat, senza comprimerla con altre app."
        case .noChatInArchive:
            "Lo ZIP contiene solo foto o altri file, nessun testo della chat. Esporta di nuovo la chat dall'app di messaggi."
        case let .unsupportedFile(fileExtension):
            "Sbu Chats legge le chat esportate come .txt o .zip; questo file è .\(fileExtension)."
        case .unrecognizedFormat:
            "Le righe del file non iniziano con data e ora come in una chat esportata. Qui sotto c'è la prima riga trovata."
        case .unreadableDates:
            "Le righe hanno data e ora, ma le date non tornano in nessun ordine di giorno, mese e anno. Qui sotto c'è una delle righe."
        case .noMessages:
            "Nel file non ci sono messaggi scritti da qualcuno, solo avvisi dell'app o nessuna riga."
        case .tooLarge:
            "Il testo supera 200 MB, molto più di qualsiasi chat esportata. Sbu Chats si ferma per non riempire l'iPhone."
        case .lineTooLong:
            "Una riga supera 1 MB, più di qualsiasi messaggio: il file non è una chat esportata, o è danneggiato."
        }
    }

    /// The line to show under the explanation, if the failure carries one.
    var sampleLine: String? {
        switch self {
        case let .unrecognizedFormat(line), let .unreadableDates(line): line.isEmpty ? nil : line
        default: nil
        }
    }
}
