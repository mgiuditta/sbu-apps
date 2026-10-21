import Foundation
import Testing
@testable import SbuSocial

struct ShieldSettingsTests {
    @Test func offAndEmptyUntilYouChoose() {
        let defaults = UserDefaults(suiteName: "ShieldSettingsTests-\(UUID())")!
        let settings = ShieldSettings.load(from: defaults)
        #expect(!settings.isOn)
        #expect(settings.appCount == 0)
    }

    @Test func theSwitchSurvivesARelaunch() {
        let defaults = UserDefaults(suiteName: "ShieldSettingsTests-\(UUID())")!
        var settings = ShieldSettings()
        settings.isOn = true
        settings.save(to: defaults)
        #expect(ShieldSettings.load(from: defaults) == settings)
    }
}
