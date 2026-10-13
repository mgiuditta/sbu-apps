import Foundation
import Observation

/// Live speedometer state: the latest speed, plus the current trip, the unit and the speed limit saved on this iPhone.
@Observable
final class SpeedModel {
    private static let unitKey = "unit"
    private static let tripKey = "trip"
    private static let limitKey = "speedLimit"

    private(set) var access = LocationAccess.notDetermined
    /// Metres per second; `nil` until a fix carries a valid speed.
    private(set) var speed: Double?
    private(set) var trip = Trip()
    /// Goes up by one at each crossing above the limit that should alert: the screen vibrates and sounds on each change.
    private(set) var limitAlerts = 0

    var unit: SpeedUnit {
        didSet {
            defaults.set(unit.rawValue, forKey: Self.unitKey)
            if let speedLimit, speedLimit.unit != unit {
                self.speedLimit = speedLimit.converted(to: unit)
            }
        }
    }

    /// Off by default. Always in the current unit.
    var speedLimit: SpeedLimit? {
        didSet { save(speedLimit, forKey: Self.limitKey) }
    }

    @ObservationIgnored private let source: any SpeedSource
    @ObservationIgnored private let defaults: UserDefaults
    @ObservationIgnored private var alarm = SpeedLimitAlarm()

    var status: SpeedStatus { SpeedStatus(access: access, speed: speed) }

    /// The top of the dial in the current unit: the smallest scale that holds the speed, the trip's top speed and the limit.
    var dialFullScale: Double {
        let highest = max(
            unit.value(ofMetersPerSecond: speed ?? 0),
            unit.value(ofMetersPerSecond: trip.maxSpeed),
            Double(speedLimit?.value ?? 0)
        )
        return unit.fullScale(containing: highest)
    }

    /// How much of the dial the current speed fills: 0 without a speed, up to 1 at full scale.
    var dialFraction: Double {
        guard let speed else { return 0 }
        return min(1, unit.value(ofMetersPerSecond: speed) / dialFullScale)
    }

    /// The speed on screen is above the limit.
    var isOverLimit: Bool {
        guard let speed, let speedLimit else { return false }
        return speedLimit.isExceeded(byMetersPerSecond: speed)
    }

    /// - Parameter locale: Picks km/h or mph until the person chooses a unit.
    init(source: any SpeedSource = LocationSpeedSource(), defaults: UserDefaults = .standard, locale: Locale = .current) {
        self.source = source
        self.defaults = defaults
        unit = defaults.string(forKey: Self.unitKey).flatMap(SpeedUnit.init(rawValue:)) ?? .preferred(for: locale)
        trip = Self.load(Trip.self, forKey: Self.tripKey, from: defaults) ?? Trip()
        speedLimit = Self.load(SpeedLimit.self, forKey: Self.limitKey, from: defaults)?.converted(to: unit)
    }

    /// Reads the source until the calling task is cancelled.
    func run() async {
        // fastlane snapshot runs in the simulator, which has no GPS: show a fixed drive.
        if defaults.bool(forKey: "FASTLANE_SNAPSHOT") {
            showSnapshotDrive()
            return
        }
        for await event in source.events() {
            handle(event)
        }
        source.stop()
    }

    func handle(_ event: SpeedEvent) {
        switch event {
        case .access(let newAccess):
            access = newAccess
            if newAccess != .granted {
                speed = nil
            }
        case .sample(let sample):
            speed = sample.hasValidSpeed ? sample.speed : nil
            trip.record(sample)
            save(trip, forKey: Self.tripKey)
            if alarm.shouldAlert(speed: speed, limit: speedLimit) {
                limitAlerts += 1
            }
        }
    }

    func resetTrip() {
        trip = Trip()
        save(trip, forKey: Self.tripKey)
    }

    private func save(_ value: (some Encodable)?, forKey key: String) {
        if let value, let data = try? JSONEncoder().encode(value) {
            defaults.set(data, forKey: key)
        } else {
            defaults.removeObject(forKey: key)
        }
    }

    private static func load<Value: Decodable>(_ type: Value.Type, forKey key: String, from defaults: UserDefaults) -> Value? {
        defaults.data(forKey: key).flatMap { try? JSONDecoder().decode(type, from: $0) }
    }

    private func showSnapshotDrive() {
        func metersPerSecond(_ kilometersPerHour: Double) -> Double {
            Measurement(value: kilometersPerHour, unit: UnitSpeed.kilometersPerHour).converted(to: .metersPerSecond).value
        }
        // Not saved: the screenshot drive must not replace the person's trip.
        access = .granted
        speed = metersPerSecond(52)
        trip = Trip(maxSpeed: metersPerSecond(87), distance: 12_400, movingTime: 12_400 / metersPerSecond(46))
    }
}
