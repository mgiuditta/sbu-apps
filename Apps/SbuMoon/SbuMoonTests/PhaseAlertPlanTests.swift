import Foundation
import Testing
@testable import SbuMoon

nonisolated struct PhaseAlertPlanTests {
    private let rome: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Europe/Rome") ?? .gmt
        return calendar
    }()

    /// 2024-01-20 12:00 in Rome, between the first quarter of the 18th and the full moon of the 25th.
    private let now = Date(timeIntervalSince1970: 1_705_748_400)

    @Test func nothingWithoutPhases() {
        #expect(PhaseAlertPlan.alerts(for: [], hour: 9, minute: 0, after: now, calendar: rome).isEmpty)
    }

    @Test func firstFullMoonAlertIsOnItsDayAtTheChosenTime() throws {
        let alerts = PhaseAlertPlan.alerts(for: [.full], hour: 9, minute: 30, after: now, calendar: rome)

        let first = try #require(alerts.first)
        #expect(first.phase == .full)
        // Full moon 2024-01-25 17:54 UTC, so 18:54 in Rome; the alert at 9:30 that morning.
        #expect(abs(first.eventDate.timeIntervalSince(try Date("2024-01-25T17:54:00Z", strategy: .iso8601))) < 120)
        #expect(first.fireDate == (try Date("2024-01-25T08:30:00Z", strategy: .iso8601)))
    }

    @Test func coversAboutAYearInOrderAndOnlyTheChosenPhases() {
        let alerts = PhaseAlertPlan.alerts(for: [.new, .full], hour: 9, minute: 0, after: now, calendar: rome)

        #expect((24...26).contains(alerts.count))
        #expect(alerts.allSatisfy { $0.phase == .new || $0.phase == .full })
        #expect(alerts.map(\.fireDate) == alerts.map(\.fireDate).sorted())
        #expect(alerts.allSatisfy { $0.fireDate > now && $0.fireDate < now.addingTimeInterval(PhaseAlertPlan.horizon + 86_400) })
    }

    @Test func allFourPhasesStayUnderTheSixtyFourPending() {
        let alerts = PhaseAlertPlan.alerts(for: Set(PrincipalPhase.allCases), hour: 9, minute: 0, after: now, calendar: rome)

        #expect(alerts.count <= PhaseAlertPlan.pendingLimit)
        #expect(alerts.count >= 48)
        #expect(Set(alerts.map(\.identifier)).count == alerts.count)
    }

    @Test(arguments: [1, 5, 10])
    func neverMoreThanTheLimit(limit: Int) {
        let alerts = PhaseAlertPlan.alerts(for: Set(PrincipalPhase.allCases), hour: 9, minute: 0, after: now, calendar: rome, limit: limit)

        #expect(alerts.count == limit)
    }

    @Test func aPhaseWhoseAlertTimeHasPassedTodayIsSkipped() throws {
        // At 10:00 in Rome on the full moon day, a 9:00 alert is gone; the next full moon is next.
        let fullMoonMorning = try Date("2024-01-25T09:00:00Z", strategy: .iso8601)

        let alerts = PhaseAlertPlan.alerts(for: [.full], hour: 9, minute: 0, after: fullMoonMorning, calendar: rome)

        let first = try #require(alerts.first)
        #expect(first.eventDate > (try Date("2024-02-20T00:00:00Z", strategy: .iso8601)))
    }

    @Test func anAlertLaterTodayForAPhaseThatAlreadyHappenedIsKept() throws {
        // The full moon came at 18:54 in Rome; at 19:30 a 20:00 alert for it is still to come.
        let evening = try Date("2024-01-25T18:30:00Z", strategy: .iso8601)

        let alerts = PhaseAlertPlan.alerts(for: [.full], hour: 20, minute: 0, after: evening, calendar: rome)

        let first = try #require(alerts.first)
        #expect(first.fireDate == (try Date("2024-01-25T19:00:00Z", strategy: .iso8601)))
    }
}
