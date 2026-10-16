import Foundation

/// Where the remote stands with the current TV, said in words and an SF Symbol, never color alone.
nonisolated enum ConnectionStatus: Equatable, Sendable {
    case noTV
    case connecting
    case connected
    case notPaired
    case unreachable
    case localNetworkDenied

    init(_ error: any Error) {
        switch error as? TVClientError {
        case .notPaired, .rejected: self = .notPaired
        case .localNetworkDenied: self = .localNetworkDenied
        default: self = .unreachable
        }
    }

    var title: LocalizedStringResource {
        switch self {
        case .noTV: "Nessuna TV"
        case .connecting: "Mi collego"
        case .connected: "Collegata"
        case .notPaired: "Da collegare di nuovo"
        case .unreachable: "Non raggiungibile"
        case .localNetworkDenied: "Rete locale disattivata"
        }
    }

    var systemImage: String {
        switch self {
        case .noTV: "tv"
        case .connecting: "antenna.radiowaves.left.and.right"
        case .connected: "checkmark.circle"
        case .notPaired: "link"
        case .unreachable: "wifi.exclamationmark"
        case .localNetworkDenied: "exclamationmark.triangle"
        }
    }

    /// Keys only work while connected; elsewhere they are dimmed.
    var acceptsKeys: Bool { self == .connected }
}
