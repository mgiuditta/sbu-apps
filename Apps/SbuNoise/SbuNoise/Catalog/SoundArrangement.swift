import Foundation

/// How the user arranged the catalog in Gestisci: their order and the sounds they hid.
/// Sounds the arrangement does not know yet (new in an update) follow, in catalog order.
nonisolated struct SoundArrangement: Equatable, Sendable {
    /// Sound ids in the user's order; may hold ids of sounds that no longer exist.
    var order: [String] = []
    var hidden: Set<String> = []

    /// Every sound of `catalog`, hidden ones included, in the user's order.
    func arranged(_ catalog: [Sound]) -> [Sound] {
        let byID = Dictionary(uniqueKeysWithValues: catalog.map { ($0.id, $0) })
        let ordered = order.compactMap { byID[$0] }
        let known = Set(order)
        return ordered + catalog.filter { !known.contains($0.id) }
    }

    /// The sounds the player shows, in the user's order.
    func visible(_ catalog: [Sound]) -> [Sound] {
        arranged(catalog).filter { !hidden.contains($0.id) }
    }

    /// Moves visible sounds as `List.onMove` reports it; hidden sounds keep their place after them.
    mutating func move(fromOffsets source: IndexSet, toOffset destination: Int, in catalog: [Sound]) {
        let visible = visible(catalog).map(\.id)
        let moving = source.filter(visible.indices.contains).map { visible[$0] }
        var staying = visible.indices.filter { !source.contains($0) }.map { visible[$0] }
        let insertion = min(destination - source.count { $0 < destination }, staying.count)
        staying.insert(contentsOf: moving, at: max(0, insertion))
        order = staying + arranged(catalog).map(\.id).filter(hidden.contains)
    }

    mutating func hide(_ id: String) {
        hidden.insert(id)
    }

    mutating func show(_ id: String) {
        hidden.remove(id)
    }
}
