import Foundation

/// What a page of the player plays: a sound of the catalog or a saved mix.
nonisolated enum PlayerItem: Identifiable, Sendable {
    case sound(Sound)
    case mix(Mix)

    var id: String {
        switch self {
        case .sound(let sound): sound.id
        case .mix(let mix): mix.id.uuidString
        }
    }

    var name: String {
        switch self {
        case .sound(let sound): String(localized: sound.name)
        case .mix(let mix): mix.name
        }
    }

    var systemImage: String {
        switch self {
        case .sound(let sound): sound.systemImage
        case .mix: "square.stack.3d.up"
        }
    }
}
