import Foundation
import Observation
import WidgetKit

/// The saved TVs, kept in the App Group so the widget and Shortcuts see the same list.
/// No credential is ever here: those stay in the Keychain (`CredentialStore`).
@Observable
final class TVStore {
    private(set) var list: SavedTVList

    @ObservationIgnored private let defaults: UserDefaults
    @ObservationIgnored private let credentials: CredentialStore
    nonisolated static let key = "savedTVs"

    init(defaults: UserDefaults = UserDefaults(suiteName: AppGroup.identifier) ?? .standard, credentials: CredentialStore = .shared) {
        self.defaults = defaults
        self.credentials = credentials
        list = Self.load(from: defaults)
    }

    var tvs: [SavedTV] { list.tvs }
    var current: SavedTV? { list.current }

    func add(_ tv: SavedTV) {
        let replaced = list.add(tv)
        save()
        Task { [credentials] in
            for id in replaced { try? await credentials.remove(for: id) }
        }
    }

    func use(_ tv: SavedTV) {
        list.use(tv.id)
        save()
    }

    func rename(_ tv: SavedTV, to name: String) {
        list.rename(tv.id, to: name)
        save()
    }

    func updateHost(_ tv: SavedTV, to host: String) {
        list.updateHost(tv.id, to: host)
        save()
    }

    /// Forgets the TV and its credential: pairing again shows the prompt or code on the TV.
    func forget(_ tv: SavedTV) async {
        list.remove(tv.id)
        save()
        try? await credentials.remove(for: tv.id)
    }

    /// Reads the list the widget or an intent may have changed.
    func reload() {
        list = Self.load(from: defaults)
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(list) else { return }
        defaults.set(data, forKey: Self.key)
        WidgetCenter.shared.reloadAllTimelines()
    }

    nonisolated static func load(from defaults: UserDefaults) -> SavedTVList {
        guard let data = defaults.data(forKey: key), let list = try? JSONDecoder().decode(SavedTVList.self, from: data) else {
            return SavedTVList()
        }
        return list
    }
}
