import Foundation

/// The TVs the user paired, in the order they were added, and the one used last.
nonisolated struct SavedTVList: Codable, Equatable, Sendable {
    private(set) var tvs: [SavedTV] = []
    private(set) var lastUsedID: UUID?

    /// The TV the remote opens on: the last one used, or the first saved.
    var current: SavedTV? {
        tvs.first { $0.id == lastUsedID } ?? tvs.first
    }

    /// Saves a newly paired TV and makes it current. A TV paired again at the same address
    /// replaces the old entry; the ids it replaced are returned so their credentials can go.
    @discardableResult
    mutating func add(_ tv: SavedTV) -> [UUID] {
        let replaced = tvs.filter { $0.id != tv.id && $0.host == tv.host && $0.brand == tv.brand }.map(\.id)
        tvs.removeAll { replaced.contains($0.id) || $0.id == tv.id }
        tvs.append(tv)
        lastUsedID = tv.id
        return replaced
    }

    mutating func use(_ id: UUID) {
        guard tvs.contains(where: { $0.id == id }) else { return }
        lastUsedID = id
    }

    mutating func remove(_ id: UUID) {
        tvs.removeAll { $0.id == id }
        if lastUsedID == id { lastUsedID = tvs.first?.id }
    }

    /// Renames a TV; an empty name keeps the old one.
    mutating func rename(_ id: UUID, to name: String) {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, let index = tvs.firstIndex(where: { $0.id == id }) else { return }
        tvs[index].name = trimmed
    }

    /// Records the address a TV has now, after the router gave it a new one.
    mutating func updateHost(_ id: UUID, to host: String) {
        guard let index = tvs.firstIndex(where: { $0.id == id }) else { return }
        tvs[index].host = host
    }
}
