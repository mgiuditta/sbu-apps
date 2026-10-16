import Foundation
import Testing
@testable import SbuFind

struct BreathingTests {
    let defaults: UserDefaults

    init() throws {
        defaults = try #require(UserDefaults(suiteName: "BreathingTests-\(UUID().uuidString)"))
    }

    @Test func breathesByDefault() {
        #expect(Breathing.isAllowed(reduceMotion: false, defaults: defaults))
    }

    @Test func reduceMotionStopsIt() {
        #expect(!Breathing.isAllowed(reduceMotion: true, defaults: defaults))
    }

    @Test(arguments: ["STILL_ANIMATIONS", "FASTLANE_SNAPSHOT"])
    func testsAndScreenshotsStopIt(key: String) {
        defaults.set(true, forKey: key)
        #expect(!Breathing.isAllowed(reduceMotion: false, defaults: defaults))
    }
}
