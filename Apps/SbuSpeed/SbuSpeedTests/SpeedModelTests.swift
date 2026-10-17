import Foundation
import Testing
@testable import SbuSpeed

struct SpeedModelTests {
    private let defaults: UserDefaults
    /// In memory: the tests never touch the trips saved on the simulator.
    private let tripLog = TripLog(trips: [])

    init() throws {
        defaults = try #require(UserDefaults(suiteName: "SpeedModelTests-\(UUID().uuidString)"))
    }

    private func model(_ events: [SpeedEvent] = [], locale: String = "it_IT") -> SpeedModel {
        SpeedModel(source: FakeSpeedSource(events), defaults: defaults, locale: Locale(identifier: locale), tripLog: tripLog)
    }

    @Test func runShowsTheLatestSpeedAndRecordsTheTrip() async {
        let source = FakeSpeedSource([
            .access(.granted),
            .sample(.fix(at: 0, metersNorth: 0, speed: 10)),
            .sample(.fix(at: 1, metersNorth: 14, speed: 14)),
        ])
        let model = SpeedModel(source: source, defaults: defaults, locale: Locale(identifier: "it_IT"), tripLog: tripLog)

        await model.run()

        #expect(model.speed == 14)
        #expect(model.status == .moving)
        #expect(model.trip.maxSpeed == 14)
        #expect(abs(model.trip.distance - 14) < 0.5)
        #expect(source.isStopped)
    }

    @Test func fixWithoutSpeedEmptiesTheFigure() async {
        let model = model([
            .access(.granted),
            .sample(.fix(at: 0, speed: 10)),
            .sample(.fix(at: 1, speed: -1, speedAccuracy: -1)),
        ])

        await model.run()

        #expect(model.speed == nil)
        #expect(model.status == .searching)
    }

    @Test(arguments: [LocationAccess.denied, .approximate, .notDetermined])
    func losingAccessEmptiesTheFigureButKeepsTheTrip(access: LocationAccess) async {
        let model = model([
            .access(.granted),
            .sample(.fix(at: 0, speed: 10)),
            .access(access),
        ])

        await model.run()

        #expect(model.speed == nil)
        #expect(model.trip.maxSpeed == 10)
    }

    @Test func resetStartsANewTrip() async {
        let model = model([.access(.granted), .sample(.fix(at: 0, speed: 10))])
        await model.run()

        model.resetTrip()

        #expect(model.trip.isEmpty)
        #expect(model.speed == 10)
    }

    @Test func tripGoesOnAfterARelaunch() async {
        let first = model([
            .access(.granted),
            .sample(.fix(at: 0, metersNorth: 0, speed: 10)),
            .sample(.fix(at: 1, metersNorth: 14, speed: 14)),
        ])
        await first.run()

        let second = model()

        #expect(second.trip.maxSpeed == 14)
        #expect(second.trip.distance == first.trip.distance)
        #expect(second.trip.movingTime == first.trip.movingTime)
    }

    @Test func resetClearsTheSavedTrip() async {
        let first = model([.access(.granted), .sample(.fix(at: 0, speed: 10))])
        await first.run()

        first.resetTrip()

        #expect(model().trip.isEmpty)
    }

    @Test func speedLimitIsOffByDefault() {
        #expect(model().speedLimit == nil)
    }

    @Test func goingOverTheLimitAlertsOnceAndShowsIt() async {
        // 50 km/h is 13.9 m/s.
        let model = model([
            .access(.granted),
            .sample(.fix(at: 0, speed: 12)),
            .sample(.fix(at: 1, speed: 15)),
            .sample(.fix(at: 2, speed: 16)),
        ])
        model.speedLimit = SpeedLimit(value: 50, unit: .kilometersPerHour)

        await model.run()

        #expect(model.limitAlerts == 1)
        #expect(model.isOverLimit)
    }

    @Test func belowTheLimitNothingIsShown() async {
        let model = model([.access(.granted), .sample(.fix(at: 0, speed: 12))])
        model.speedLimit = SpeedLimit(value: 50, unit: .kilometersPerHour)

        await model.run()

        #expect(model.limitAlerts == 0)
        #expect(model.isOverLimit == false)
    }

    @Test func speedLimitIsSavedAndFollowsTheUnit() {
        let first = model(locale: "it_IT")
        first.speedLimit = SpeedLimit(value: 50, unit: .kilometersPerHour)

        first.unit = .milesPerHour

        #expect(first.speedLimit == SpeedLimit(value: 30, unit: .milesPerHour))
        #expect(model(locale: "it_IT").speedLimit == SpeedLimit(value: 30, unit: .milesPerHour))
    }

    @Test func knotsAreSavedWithTheLimitInKnots() {
        let first = model(locale: "it_IT")
        first.speedLimit = SpeedLimit(value: 50, unit: .kilometersPerHour)

        first.unit = .knots

        let second = model(locale: "it_IT")
        #expect(second.unit == .knots)
        #expect(second.speedLimit == SpeedLimit(value: 27, unit: .knots))
    }

    @Test func limitAlertWorksInKnots() async {
        // 10 knots is 5.14 m/s: 6 m/s reads 12 kn, over the limit.
        let model = model([.access(.granted), .sample(.fix(at: 0, speed: 6))])
        model.unit = .knots
        model.speedLimit = SpeedLimit(value: 10, unit: .knots)

        await model.run()

        #expect(model.isOverLimit)
        #expect(model.limitAlerts == 1)
    }

    @Test func turningTheLimitOffIsSaved() {
        let first = model()
        first.speedLimit = SpeedLimit(value: 50, unit: .kilometersPerHour)

        first.speedLimit = nil

        #expect(model().speedLimit == nil)
    }

    @Test(arguments: [("it_IT", SpeedUnit.kilometersPerHour), ("en_US", .milesPerHour)])
    func unitDefaultsToTheRegion(locale: String, expected: SpeedUnit) {
        #expect(model(locale: locale).unit == expected)
    }

    @Test func chosenUnitIsSavedOnTheDevice() {
        let first = model(locale: "it_IT")
        first.unit = .milesPerHour

        let second = model(locale: "it_IT")

        #expect(second.unit == .milesPerHour)
    }

    @Test func snapshotModeShowsAFixedDriveWithoutReadingTheSource() async {
        defaults.set(true, forKey: "FASTLANE_SNAPSHOT")
        let source = FakeSpeedSource([.access(.denied)])
        let model = SpeedModel(source: source, defaults: defaults, locale: Locale(identifier: "it_IT"), tripLog: tripLog)

        await model.run()

        #expect(model.status == .moving)
        #expect(SpeedFigureStyle(unit: .kilometersPerHour).locale(Locale(identifier: "it_IT")).format(model.speed) == "52")
        #expect(source.isStopped == false)
        defaults.removeObject(forKey: "FASTLANE_SNAPSHOT")
        #expect(SpeedModel(source: FakeSpeedSource([]), defaults: defaults, tripLog: tripLog).trip.isEmpty)
    }

    @Test func quickLimitTurnsOnAndOffWithATap() {
        let model = model(locale: "it_IT")
        let limit = SpeedLimit(value: 90, unit: .kilometersPerHour)

        model.toggleLimit(limit)
        #expect(model.speedLimit == limit)

        model.toggleLimit(SpeedLimit(value: 130, unit: .kilometersPerHour))
        #expect(model.speedLimit?.value == 130)

        model.toggleLimit(SpeedLimit(value: 130, unit: .kilometersPerHour))
        #expect(model.speedLimit == nil)
    }

    @Test(arguments: [("en_US", [25, 55, 65, 70]), ("en_GB", [20, 30, 60, 70])])
    func quickLimitsInMilesFollowTheRegion(locale: String, expected: [Int]) {
        let model = model(locale: locale)
        model.unit = .milesPerHour

        #expect(model.quickLimits.map(\.value) == expected)
    }

    @Test func navigationFollowsTheLatestFixAndClearsWithoutAccess() async {
        let moving = model([
            .access(.granted),
            .sample(.fix(at: 0, speed: 10, altitude: 120, verticalAccuracy: 5, course: 90)),
            .sample(.fix(at: 1, speed: 10, altitude: 125, verticalAccuracy: 5, course: 95)),
        ])
        await moving.run()
        #expect(moving.navigation == NavigationReading(altitude: 125, course: 95))

        let lost = model([
            .access(.granted),
            .sample(.fix(at: 0, speed: 10, altitude: 120, verticalAccuracy: 5, course: 90)),
            .access(.denied),
        ])
        await lost.run()
        #expect(lost.navigation == NavigationReading())
    }

    @Test func saveAndResetKeepsATripThatWentSomewhere() async throws {
        let model = model([
            .access(.granted),
            .sample(.fix(at: 0, metersNorth: 0, speed: 10)),
            .sample(.fix(at: 1, metersNorth: 14, speed: 14)),
        ])
        await model.run()
        #expect(model.canSaveTrip)

        let didSave = model.saveAndResetTrip()

        #expect(didSave)
        let saved = try #require(tripLog.trips.first)
        #expect(tripLog.trips.count == 1)
        #expect(saved.maxSpeed == 14)
        #expect(abs(saved.distance - 14) < 0.5)
        #expect(saved.startedAt == SpeedSample.fix(at: 0, speed: 10).timestamp)
        #expect(saved.endedAt == SpeedSample.fix(at: 1, speed: 14).timestamp)
        #expect(model.trip.isEmpty)
    }

    @Test func saveAndResetWithoutDistanceOnlyResets() async {
        // One fix: a top speed but no distance.
        let model = model([.access(.granted), .sample(.fix(at: 0, speed: 10))])
        await model.run()
        #expect(model.canSaveTrip == false)
        #expect(model.trip.isEmpty == false)

        let didSave = model.saveAndResetTrip()

        #expect(didSave == false)
        #expect(tripLog.trips.isEmpty)
        #expect(model.trip.isEmpty)
    }

    @Test func aFixSetsTheGPSAccuracyAndLosingAccessClearsIt() {
        let model = model()

        model.handle(.access(.granted))
        model.handle(.sample(.fix(at: 0, speed: 10, horizontalAccuracy: 20)))
        let withFix = model.gpsAccuracy
        model.handle(.access(.denied))

        #expect(withFix == .good)
        #expect(model.gpsAccuracy == .none)
    }
}
