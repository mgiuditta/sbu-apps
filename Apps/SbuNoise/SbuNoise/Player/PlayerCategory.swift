import Foundation

/// The lists the ☰ menu switches between, as in the original. The playlist joins with its ticket.
nonisolated enum PlayerCategory: String, CaseIterable, Identifiable, Sendable {
    case sounds
    case favorites
    case mixes

    var id: Self { self }

    var title: LocalizedStringResource {
        switch self {
        case .sounds: "Suoni"
        case .favorites: "Preferiti"
        case .mixes: "Mix"
        }
    }

    var systemImage: String {
        switch self {
        case .sounds: "waveform"
        case .favorites: "heart"
        case .mixes: "square.stack.3d.up"
        }
    }
}
