import Foundation
import Testing
@testable import SbuShrink

struct PreferencesTests {
    private let defaults: UserDefaults

    init() {
        let suite = "prefs-\(UUID().uuidString)"
        defaults = UserDefaults(suiteName: suite) ?? .standard
        defaults.removePersistentDomain(forName: suite)
    }

    @Test func theFirstLaunchHasTheSuggestedSettingsAndTheAlbum() {
        let preferences = Preferences(defaults: defaults)
        #expect(preferences.settings == CompressionSettings())
        #expect(preferences.savesToAlbum)
    }

    @Test func settingsRoundTrip() {
        let preferences = Preferences(defaults: defaults)
        let settings = CompressionSettings(frameRate: 15, dimensionPercent: 35, qualityPercent: 45, targetMegabytes: 9.5, codec: .hevc, removesAudio: true, convertsToMP4: true)
        preferences.settings = settings
        #expect(Preferences(defaults: defaults).settings == settings)
        preferences.savesToAlbum = false
        #expect(!Preferences(defaults: defaults).savesToAlbum)
    }

    @Test(arguments: [Data(), Data("garbage".utf8), Data("[]".utf8), Data(#"{"frameRate": 1e400}"#.utf8)])
    func unreadableStoredSettingsFallBackToTheSuggestedOnes(data: Data) {
        defaults.set(data, forKey: Preferences.settingsKey)
        #expect(Preferences(defaults: defaults).settings == CompressionSettings())
    }

    @Test func aStoredValueOfTheWrongTypeIsIgnored() {
        defaults.set("yes", forKey: Preferences.savesToAlbumKey)
        defaults.set(42, forKey: Preferences.settingsKey)
        let preferences = Preferences(defaults: defaults)
        #expect(preferences.savesToAlbum)
        #expect(preferences.settings == CompressionSettings())
    }
}
