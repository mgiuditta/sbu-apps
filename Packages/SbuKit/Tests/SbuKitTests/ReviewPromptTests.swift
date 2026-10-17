import Foundation
import Testing
@testable import SbuKit

/// The review is asked after the Closure on three different days, once per version.
struct ReviewPromptTests {
    private let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Europe/Rome")!
        return calendar
    }()

    private func day(_ day: Int, hour: Int = 12) -> Date {
        calendar.date(from: DateComponents(year: 2026, month: 10, day: day, hour: hour))!
    }

    private func prompt(closingOn days: [Date]) -> SbuReviewPrompt {
        var prompt = SbuReviewPrompt()
        for date in days {
            prompt.recordClosure(on: date, calendar: calendar)
        }
        return prompt
    }

    @Test func asksAfterThreeDifferentDays() {
        #expect(prompt(closingOn: [day(1), day(2), day(5)]).shouldAsk(version: "1.0"))
    }

    @Test(arguments: [0, 1, 2])
    func waitsForThreeDays(count: Int) {
        let days = (1...3).prefix(count).map { day($0) }
        #expect(!prompt(closingOn: days).shouldAsk(version: "1.0"))
    }

    @Test func manyClosuresOnOneDayCountOnce() {
        #expect(!prompt(closingOn: [day(1, hour: 8), day(1, hour: 13), day(1, hour: 22)]).shouldAsk(version: "1.0"))
    }

    @Test func asksOncePerVersion() {
        var prompt = prompt(closingOn: [day(1), day(2), day(3)])
        prompt.markAsked(version: "1.0")
        prompt.recordClosure(on: day(4), calendar: calendar)
        prompt.recordClosure(on: day(5), calendar: calendar)
        prompt.recordClosure(on: day(6), calendar: calendar)

        #expect(!prompt.shouldAsk(version: "1.0"))
        #expect(prompt.shouldAsk(version: "1.1"))
    }

    @Test func aNewVersionStillNeedsNewDays() {
        var prompt = prompt(closingOn: [day(1), day(2), day(3)])
        prompt.markAsked(version: "1.0")

        #expect(!prompt.shouldAsk(version: "1.1"))
    }

    @Test func survivesRelaunch() throws {
        let defaults = try #require(UserDefaults(suiteName: "ReviewPromptTests.\(UUID())"))
        let saved = prompt(closingOn: [day(1), day(2)])
        saved.save(to: defaults)

        #expect(SbuReviewPrompt(defaults: defaults) == saved)
    }
}
