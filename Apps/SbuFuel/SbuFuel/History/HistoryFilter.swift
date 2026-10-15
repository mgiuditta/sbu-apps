import Foundation

/// What the history shows.
nonisolated enum HistoryFilter: String, CaseIterable, Identifiable, Sendable {
    case all
    case fuel
    case services

    var id: Self { self }

    var name: LocalizedStringResource {
        switch self {
        case .all: "Tutto"
        case .fuel: "Rifornimenti"
        case .services: "Interventi"
        }
    }
}
