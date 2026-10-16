import Foundation

/// What the app remembers between launches: the last compression settings and whether copies
/// also go in the album. Nothing else is stored.
nonisolated struct Preferences {
    static let settingsKey = "compressionSettings"
    static let savesToAlbumKey = "savesToAlbum"

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    /// The settings of the last batch; the suggested ones the first time or if the stored ones
    /// cannot be read.
    var settings: CompressionSettings {
        get {
            guard let data = defaults.data(forKey: Self.settingsKey),
                  let settings = try? JSONDecoder().decode(CompressionSettings.self, from: data) else {
                return CompressionSettings()
            }
            return settings
        }
        nonmutating set {
            defaults.set(try? JSONEncoder().encode(newValue), forKey: Self.settingsKey)
        }
    }

    /// On by default, as in the original: copies go in the library and in "Video compressi".
    var savesToAlbum: Bool {
        get { defaults.object(forKey: Self.savesToAlbumKey) as? Bool ?? true }
        nonmutating set { defaults.set(newValue, forKey: Self.savesToAlbumKey) }
    }
}
