import Foundation

/// Why a file couldn't be imported, in words.
enum ImportFailure: LocalizedError {
    case unreadable
    case empty

    var errorDescription: String? {
        switch self {
        case .unreadable: String(localized: "Il file non si legge.")
        case .empty: String(localized: "Nel file non ci sono righe da importare: serve una riga di intestazione e almeno una voce.")
        }
    }
}
