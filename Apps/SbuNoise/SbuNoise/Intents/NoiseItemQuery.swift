import AppIntents

/// The sounds, then the mixes, read from the Noise file.
nonisolated struct NoiseItemQuery: EnumerableEntityQuery {
    func allEntities() async throws -> [NoiseItemEntity] {
        Self.entities(mixes: (try? NoiseStore.shared.load().mixes) ?? [])
    }

    func entities(for identifiers: [NoiseItemEntity.ID]) async throws -> [NoiseItemEntity] {
        try await allEntities().filter { identifiers.contains($0.id) }
    }

    static func entities(sounds: [Sound] = Sound.catalog, mixes: [Mix]) -> [NoiseItemEntity] {
        sounds.map { NoiseItemEntity(.sound($0)) } + mixes.map { NoiseItemEntity(.mix($0)) }
    }
}
