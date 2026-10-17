import Foundation

/// Where the remote stands with the current TV, said in words beside the row mark, never color alone.
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

    /// Keys only work while connected; elsewhere they are dimmed.
    var acceptsKeys: Bool { self == .connected }
}
