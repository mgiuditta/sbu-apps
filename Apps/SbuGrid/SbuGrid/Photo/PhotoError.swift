import Foundation

/// Why a photo did not open.
nonisolated enum PhotoError: Error, Equatable, Sendable {
    /// The Photos picker gave nothing: the photo is on iCloud and did not download, or it went.
    case unavailable
    /// The data is not a picture iOS can read.
    case unreadable

    /// What the alert says, and what to do about it.
    var message: LocalizedStringResource {
        switch self {
        case .unavailable: "La foto non è arrivata. Se è su iCloud, controlla la connessione e riprova."
        case .unreadable: "Questo file non è una foto che iPhone sa leggere. Scegline un'altra."
        }
    }
}
