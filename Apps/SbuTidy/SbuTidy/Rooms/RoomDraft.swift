import Foundation

/// What the room form edits: a kind, a name, and whether to add its base chores.
nonisolated struct RoomDraft: Equatable, Sendable {
    /// Long enough for "Camera degli ospiti al piano di sopra", short enough for a row.
    static let maxNameLength = 40

    var kind: RoomKind
    var name: String
    /// New rooms only: Tody's base chores for the kind, so a room is never born empty.
    var addsBaseChores = true

    init(kind: RoomKind = .kitchen, name: String? = nil) {
        self.kind = kind
        self.name = name ?? String(localized: kind.name)
    }

    /// The name as saved: trimmed, cut at `maxNameLength`.
    var cleanName: String {
        String(name.trimmingCharacters(in: .whitespacesAndNewlines).prefix(Self.maxNameLength))
    }

    var isValid: Bool { !cleanName.isEmpty }

    /// Picking a kind renames the room only while the name is still the old kind's own.
    mutating func select(_ newKind: RoomKind) {
        if cleanName.isEmpty || cleanName == String(localized: kind.name) {
            name = String(localized: newKind.name)
        }
        kind = newKind
    }
}
