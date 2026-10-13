import Foundation

/// The lists the ☰ menu switches between, as in the original: all the sounds, the favorites, the
/// mixes, then one list per group of the catalog. The playlist joins with its ticket.
nonisolated enum PlayerCategory: Hashable, Identifiable, Sendable {
    case sounds
    case favorites
    case mixes
    case group(SoundCategory)

    /// The lists above the catalog's groups in the menu.
    static let lists: [PlayerCategory] = [.sounds, .favorites, .mixes]

    var id: String { rawValue }

    /// Saved as the last category: "sounds", "favorites", "mixes", "group.rain".
    var rawValue: String {
        switch self {
        case .sounds: "sounds"
        case .favorites: "favorites"
        case .mixes: "mixes"
        case .group(let category): "group.\(category.rawValue)"
        }
    }

    init?(rawValue: String) {
        switch rawValue {
        case "sounds": self = .sounds
        case "favorites": self = .favorites
        case "mixes": self = .mixes
        default:
            guard rawValue.hasPrefix("group."), let category = SoundCategory(rawValue: String(rawValue.dropFirst(6))) else { return nil }
            self = .group(category)
        }
    }

    var title: LocalizedStringResource {
        switch self {
        case .sounds: "Suoni"
        case .favorites: "Preferiti"
        case .mixes: "Mix"
        case .group(let category): category.title
        }
    }

    var systemImage: String {
        switch self {
        case .sounds: "waveform"
        case .favorites: "heart"
        case .mixes: "square.stack.3d.up"
        case .group(let category): category.systemImage
        }
    }
}
