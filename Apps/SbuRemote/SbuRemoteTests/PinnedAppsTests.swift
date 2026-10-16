import Foundation
import Testing
@testable import SbuRemote

struct PinnedAppsTests {
    private let tv = UUID()
    private let other = UUID()
    private let apps = ["YouTube", "Netflix", "RaiPlay", "Spotify"].map { TVShortcut(id: $0.lowercased(), name: $0) }

    @Test func pinsAtMostThreePerTV() {
        var pins = PinnedApps()
        for app in apps { pins.toggle(app, for: tv) }
        #expect(pins.apps(for: tv).map(\.name) == ["YouTube", "Netflix", "RaiPlay"])
        #expect(!pins.canPin(for: tv))
        #expect(pins.apps(for: other).isEmpty)
    }

    @Test func toggleUnpins() {
        var pins = PinnedApps()
        pins.toggle(apps[0], for: tv)
        #expect(pins.isPinned(apps[0], for: tv))
        pins.toggle(apps[0], for: tv)
        #expect(!pins.isPinned(apps[0], for: tv))
        #expect(pins.canPin(for: tv))
    }

    @Test func storePersists() throws {
        let defaults = try #require(UserDefaults(suiteName: "PinnedAppsTests.\(UUID().uuidString)"))
        PinnedAppsStore(defaults: defaults).toggle(apps[1], for: tv)
        #expect(PinnedAppsStore(defaults: defaults).pins.apps(for: tv) == [apps[1]])
    }
}
