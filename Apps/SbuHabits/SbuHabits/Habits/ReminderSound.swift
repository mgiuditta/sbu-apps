import Foundation

/// The sound a habit's notifications play: iOS's own, one of the few Sbu sounds bundled in the
/// app (iOS lets no app pick a system sound), or none.
nonisolated enum ReminderSound: String, Codable, CaseIterable, Sendable {
    case standard = "default"
    case carta
    case punto
    case silent

    var title: LocalizedStringResource {
        switch self {
        case .standard: "Predefinito"
        case .carta: "Carta"
        case .punto: "Punto"
        case .silent: "Nessuno"
        }
    }

    /// The bundled file, made by `Tools/make_sounds.py`; `nil` for iOS's sound and for none.
    var fileName: String? {
        switch self {
        case .carta: "SbuCarta.caf"
        case .punto: "SbuPunto.caf"
        case .standard, .silent: nil
        }
    }
}
