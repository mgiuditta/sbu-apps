import Foundation
import Observation

/// What the user made and keeps in the Noise file: the mixes, the favorites and how the catalog
/// is arranged.
@Observable
final class Library {
    private(set) var mixes: [Mix]
    /// Sound ids and mix UUIDs (`PlayerItem.id`), in the order they were added.
    private(set) var favorites: [String]
    /// The order and the hidden sounds from Gestisci.
    var arrangement: SoundArrangement {
        didSet { commit() }
    }

    @ObservationIgnored private let store: NoiseStore

    init(store: NoiseStore = .shared) {
        self.store = store
        // ponytail: an unreadable file starts empty; a newer version is never overwritten by `save`.
        let file = (try? store.load()) ?? NoiseFile()
        mixes = file.mixes
        favorites = file.favorites
        arrangement = file.arrangement
    }

    /// Adds the mix or replaces the one with the same id.
    func save(_ mix: Mix) {
        if let index = mixes.firstIndex(where: { $0.id == mix.id }) {
            mixes[index] = mix
        } else {
            mixes.append(mix)
        }
        commit()
    }

    /// Deletes the mix, and its heart with it.
    func delete(_ id: Mix.ID) {
        mixes.removeAll { $0.id == id }
        favorites.removeAll { $0 == id.uuidString }
        commit()
    }

    /// "Mix 3": the first number not taken by a mix with that name.
    func newMixName() -> String {
        let names = Set(mixes.map(\.name))
        let number = (1...).first { !names.contains(String(localized: "Mix \($0)")) }!
        return String(localized: "Mix \(number)")
    }

    // MARK: Favorites

    func isFavorite(_ itemID: String) -> Bool {
        favorites.contains(itemID)
    }

    /// Adds the item at the end of the favorites, or takes it out.
    func toggleFavorite(_ itemID: String) {
        if isFavorite(itemID) {
            favorites.removeAll { $0 == itemID }
        } else {
            favorites.append(itemID)
        }
        commit()
    }

    private func commit() {
        try? store.update { file in
            file.mixes = mixes
            file.favorites = favorites
            file.arrangement = arrangement
        }
        // The mixes Siri and Comandi rapidi offer in "Riproduci … con Sbu Noise".
        NoiseShortcuts.updateAppShortcutParameters()
    }
}
