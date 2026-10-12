import Testing
@testable import SbuSpeed

struct SpeedLimitAlarmTests {
    private let limit = SpeedLimit(value: 50, unit: .kilometersPerHour)

    /// Feeds speeds in km/h (`nil` for a lost fix) and returns which readings alerted.
    private func alerts(_ kilometersPerHour: [Double?], limit: SpeedLimit?) -> [Bool] {
        var alarm = SpeedLimitAlarm()
        return kilometersPerHour.map { alarm.shouldAlert(speed: $0.map { $0 / 3.6 }, limit: limit) }
    }

    @Test func alertsOnceWhenGoingOver() {
        #expect(alerts([40, 49, 55, 60, 58], limit: limit) == [false, false, true, false, false])
    }

    @Test func jitterAroundTheLimitStaysSilent() {
        #expect(alerts([52, 49, 51, 48, 52], limit: limit) == [true, false, false, false, false])
    }

    @Test func slowingClearlyBelowAlertsAgainAtTheNextCrossing() {
        #expect(alerts([52, 47, 52], limit: limit) == [true, false, true])
    }

    @Test func lostFixDoesNotAlertAgain() {
        #expect(alerts([52, nil, 52], limit: limit) == [true, false, false])
    }

    @Test func noLimitNeverAlerts() {
        #expect(alerts([30, 200, 300], limit: nil) == [false, false, false])
    }
}
