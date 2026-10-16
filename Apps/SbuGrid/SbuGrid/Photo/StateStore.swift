import Foundation

/// Keeps the grid choices in UserDefaults, as JSON, between launches.
struct StateStore {
    private let defaults: UserDefaults
    private let key: String

    init(defaults: UserDefaults = .standard, key: String = "gridState") {
        self.defaults = defaults
        self.key = key
    }

    /// The saved state, or the defaults when nothing was saved or it no longer decodes.
    func load() -> GridState {
        guard let data = defaults.data(forKey: key),
              let state = try? JSONDecoder().decode(GridState.self, from: data)
        else { return GridState() }
        return state
    }

    func save(_ state: GridState) {
        guard let data = try? JSONEncoder().encode(state) else { return }
        defaults.set(data, forKey: key)
    }

    func remove() {
        defaults.removeObject(forKey: key)
    }
}
