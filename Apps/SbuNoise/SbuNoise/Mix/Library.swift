import Foundation
import Observation

/// What the user made and keeps in the Noise file: the mixes, for now.
@Observable
final class Library {
    private(set) var mixes: [Mix]

    @ObservationIgnored private let store: NoiseStore

    init(store: NoiseStore = .shared) {
        self.store = store
        // ponytail: an unreadable file starts empty; a newer version is never overwritten by `save`.
        mixes = (try? store.load().mixes) ?? []
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

    func delete(_ id: Mix.ID) {
        mixes.removeAll { $0.id == id }
        commit()
    }

    /// "Mix 3": the first number not taken by a mix with that name.
    func newMixName() -> String {
        let names = Set(mixes.map(\.name))
        let number = (1...).first { !names.contains(String(localized: "Mix \($0)")) }!
        return String(localized: "Mix \(number)")
    }

    private func commit() {
        try? store.update { $0.mixes = mixes }
    }
}
