import Foundation

extension HabitsImport {
    /// Why Importa could not use a file. The current data stays as it is in every case.
    nonisolated enum Failure: Error, Equatable {
        /// The file has no bytes.
        case empty
        /// Not JSON, or not a Sbu Habits file.
        case damaged
        /// Written by a newer Sbu Habits: reading it could lose what this version does not know.
        case newerVersion
        /// The file could not be opened, for example because it is still in the cloud.
        case unreadable
        /// The file was fine but writing it on this iPhone failed.
        case notSaved

        /// What is wrong, as the alert's title.
        var title: LocalizedStringResource {
            switch self {
            case .empty: "Il file è vuoto"
            case .damaged: "Il file non è di Sbu Habits"
            case .newerVersion: "Il file viene da una versione più recente"
            case .unreadable: "Il file non si apre"
            case .notSaved: "Dati non sostituiti"
            }
        }

        /// What to do next, as the alert's message.
        var message: LocalizedStringResource {
            switch self {
            case .empty, .damaged:
                "Scegli un file creato con Esporta in Sbu Habits. I dati attuali restano come sono."
            case .newerVersion:
                "Aggiorna Sbu Habits dall'App Store e importa di nuovo il file. I dati attuali restano come sono."
            case .unreadable:
                "Controlla che il file sia scaricato su questo iPhone e riprova. I dati attuali restano come sono."
            case .notSaved:
                "Il salvataggio non è riuscito. Riprova: i dati attuali restano come sono."
            }
        }
    }
}
