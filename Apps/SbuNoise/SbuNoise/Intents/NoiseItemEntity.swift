import AppIntents

/// A sound of the catalog or a saved mix, as Comandi rapidi and Siri offer it.
nonisolated struct NoiseItemEntity: AppEntity {
    static let typeDisplayRepresentation: TypeDisplayRepresentation = "Suono"
    static let defaultQuery = NoiseItemQuery()

    /// The sound's id or the mix's UUID, as `PlayerItem.id`.
    let id: String
    let name: String
    let systemImage: String

    init(_ item: PlayerItem) {
        id = item.id
        name = item.name
        systemImage = item.systemImage
    }

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(name)", image: DisplayRepresentation.Image(systemName: systemImage))
    }
}
