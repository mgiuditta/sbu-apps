import Foundation
import Testing
@testable import SbuMoon

struct MoonModelTests {
    private let defaults: UserDefaults
    private let now = Date(timeIntervalSince1970: 1_790_000_000)
    private let utc: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = .gmt
        return calendar
    }()

    init() throws {
        defaults = try #require(UserDefaults(suiteName: "MoonModelTests-\(UUID().uuidString)"))
    }

    @Test func followsNowUntilADateIsPicked() {
        let model = MoonModel(defaults: defaults)

        #expect(model.isShowingToday)
        #expect(model.date(now: now) == now)
    }

    @Test func showingAnotherDayStaysOnIt() {
        let model = MoonModel(defaults: defaults)
        let birthday = now.addingTimeInterval(-400 * 86_400)

        model.show(birthday, now: now)

        #expect(model.isShowingToday == false)
        #expect(model.date(now: now.addingTimeInterval(3_600)) == birthday)
    }

    @Test func pickingTodayGoesBackToFollowingNow() {
        let model = MoonModel(defaults: defaults)
        model.show(now.addingTimeInterval(30 * 86_400), now: now)

        model.show(now.addingTimeInterval(60), now: now)

        #expect(model.isShowingToday)
    }

    @Test func todayClearsThePickedDate() {
        let model = MoonModel(defaults: defaults)
        model.show(now.addingTimeInterval(30 * 86_400), now: now)

        model.showToday()

        #expect(model.date(now: now) == now)
    }

    @Test(arguments: [1, -1, 7])
    func showDayMovesByWholeDaysFromNow(days: Int) {
        let model = MoonModel(defaults: defaults)

        model.showDay(byAdding: days, now: now, calendar: utc)

        #expect(model.isShowingToday == false)
        #expect(model.date(now: now) == now.addingTimeInterval(Double(days) * 86_400))
    }

    @Test func showDayBackToTodayFollowsNowAgain() {
        let model = MoonModel(defaults: defaults)
        model.showDay(byAdding: 1, now: now, calendar: utc)

        model.showDay(byAdding: -1, now: now, calendar: utc)

        #expect(model.isShowingToday)
    }

    @Test func showDayStopsAtTheEndsOfTheCalendar() {
        let model = MoonModel(defaults: defaults)
        let lastDay = MoonModel.dateRange.upperBound
        model.show(lastDay, now: now, calendar: utc)

        model.showDay(byAdding: 1, now: now, calendar: utc)

        #expect(model.date(now: now) == lastDay)
    }

    @Test func snapshotsShowAFixedWaxingGibbousMoon() {
        defaults.set(true, forKey: "FASTLANE_SNAPSHOT")
        let model = MoonModel(defaults: defaults)

        let reading = MoonReading(date: model.date(now: now), calendar: .current)

        #expect(model.date(now: now) != now)
        #expect(reading.phase == .waxingGibbous)
    }
}
