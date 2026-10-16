import Foundation
import Testing
@testable import SbuLibretto

struct CourseSettingsTests {
    let defaults: UserDefaults

    init() throws {
        defaults = try #require(UserDefaults(suiteName: "CourseSettingsTests-\(UUID().uuidString)"))
    }

    @Test func aFreshInstallStartsFromTheStandardRules() {
        let settings = CourseSettings(defaults: defaults)
        #expect(settings.rules == .standard)
        #expect(settings.university.isEmpty)
        #expect(settings.course.isEmpty)
    }

    @Test func whatYouSetIsThereNextTime() {
        let settings = CourseSettings(defaults: defaults)
        settings.rules.cumLaudeValue = 33
        settings.rules.exclusion = .credits(12)
        settings.rules.rounding = .nearest
        settings.university = "Università degli Studi di Milano"
        settings.course = "Informatica"
        let reopened = CourseSettings(defaults: defaults)
        #expect(reopened.rules.cumLaudeValue == 33)
        #expect(reopened.rules.exclusion == .credits(12))
        #expect(reopened.rules.rounding == .nearest)
        #expect(reopened.university == "Università degli Studi di Milano")
        #expect(reopened.course == "Informatica")
    }

    @Test func anAbsurdValueIsSavedBackInRange() {
        let settings = CourseSettings(defaults: defaults)
        settings.rules.cumLaudeValue = 100
        settings.rules.totalCredits = -3
        #expect(settings.rules.cumLaudeValue == 35)
        #expect(settings.rules.totalCredits == 1)
        #expect(CourseSettings(defaults: defaults).rules.cumLaudeValue == 35)
    }

    @Test func aDamagedSaveFallsBackToTheStandardRules() {
        defaults.set(Data("non è JSON".utf8), forKey: CourseSettings.Key.rules)
        #expect(CourseSettings(defaults: defaults).rules == .standard)
    }
}
