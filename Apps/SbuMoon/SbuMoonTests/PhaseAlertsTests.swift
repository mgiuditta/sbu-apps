import Foundation
import Testing
@testable import SbuMoon

/// Records what the model hands to iOS, and answers the permission prompt as told.
private final class RecordingCenter: PhaseAlertCenter {
    var current: NotificationAccess
    var answer: NotificationAccess
    private(set) var requests = 0
    private(set) var scheduled: [[PlannedPhaseAlert]] = []

    init(current: NotificationAccess = .notDetermined, answer: NotificationAccess = .allowed) {
        self.current = current
        self.answer = answer
    }

    func access() async -> NotificationAccess { current }

    func requestAccess() async -> NotificationAccess {
        requests += 1
        current = answer
        return answer
    }

    func replace(with alerts: [PlannedPhaseAlert]) {
        scheduled.append(alerts)
    }
}

struct PhaseAlertsTests {
    private let defaults: UserDefaults
    private let now = Date(timeIntervalSince1970: 1_705_748_400)

    init() throws {
        defaults = try #require(UserDefaults(suiteName: "PhaseAlertsTests-\(UUID().uuidString)"))
    }

    @Test func startsWithNothingOnAtNine() {
        let alerts = PhaseAlerts(defaults: defaults, center: RecordingCenter())

        #expect(alerts.selection.isEmpty)
        #expect(alerts.minutesAfterMidnight == 9 * 60)
    }

    @Test func launchingNeverAsksForPermission() async {
        let center = RecordingCenter()
        let alerts = PhaseAlerts(defaults: defaults, center: center)

        await alerts.reschedule(now: now)

        #expect(center.requests == 0)
        #expect(center.scheduled.last?.isEmpty == true)
    }

    @Test func turningAPhaseOnAsksOnceAndSchedules() async {
        let center = RecordingCenter()
        let alerts = PhaseAlerts(defaults: defaults, center: center)
        let previous = alerts.selection

        alerts.selection[.full] = true
        let isSet = await alerts.settingsChanged(from: previous, now: now)

        #expect(isSet)
        #expect(center.requests == 1)
        #expect(alerts.access == .allowed)
        let scheduled = center.scheduled.last ?? []
        #expect(scheduled.isEmpty == false)
        #expect(scheduled.allSatisfy { $0.phase == .full })
    }

    @Test func turningAPhaseOffDoesNotAsk() async {
        let center = RecordingCenter(current: .allowed)
        let alerts = PhaseAlerts(defaults: defaults, center: center)
        alerts.selection[.full] = true
        let previous = alerts.selection

        alerts.selection[.full] = false
        let isSet = await alerts.settingsChanged(from: previous, now: now)

        #expect(isSet == false)
        #expect(center.requests == 0)
        #expect(center.scheduled.last?.isEmpty == true)
    }

    @Test func aRefusalIsShownAndNothingIsScheduled() async {
        let center = RecordingCenter(answer: .denied)
        let alerts = PhaseAlerts(defaults: defaults, center: center)
        let previous = alerts.selection

        alerts.selection[.new] = true
        let isSet = await alerts.settingsChanged(from: previous, now: now)

        #expect(isSet == false)
        #expect(alerts.isBlocked)
        #expect(center.scheduled.last?.isEmpty == true)
    }

    @Test func choicesSurviveARelaunch() async {
        let alerts = PhaseAlerts(defaults: defaults, center: RecordingCenter(current: .allowed))
        alerts.selection[.firstQuarter] = true
        alerts.selection[.lastQuarter] = true
        alerts.minutesAfterMidnight = 21 * 60 + 15
        await alerts.settingsChanged(now: now)

        let relaunched = PhaseAlerts(defaults: defaults, center: RecordingCenter())

        #expect(relaunched.selection == PhaseSelection([.firstQuarter, .lastQuarter]))
        #expect(relaunched.minutesAfterMidnight == 21 * 60 + 15)
    }

    @Test func thePickedTimeBecomesTheAlertTime() throws {
        let alerts = PhaseAlerts(defaults: defaults, center: RecordingCenter())
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = .gmt
        let picked = try Date("2024-01-20T07:45:00Z", strategy: .iso8601)

        alerts.setTime(picked, calendar: calendar)

        #expect(alerts.minutesAfterMidnight == 7 * 60 + 45)
        #expect(alerts.time(on: picked, calendar: calendar) == picked)
    }
}
