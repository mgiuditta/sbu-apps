import Foundation
import Observation

/// Live speedometer state: the latest speed, plus the current trip and the unit saved on this iPhone.
@Observable
final class SpeedModel {
    private static let unitKey = "unit"
    private static let tripKey = "trip"

    private(set) var access = LocationAccess.notDetermined
    /// Metres per second; `nil` until a fix carries a valid speed.
    private(set) var speed: Double?
    private(set) var trip = Trip()

    var unit: SpeedUnit {
        didSet { defaults.set(unit.rawValue, forKey: Self.unitKey) }
    }

    @ObservationIgnored private let source: any SpeedSource
    @ObservationIgnored private let defaults: UserDefaults

    var status: SpeedStatus { SpeedStatus(access: access, speed: speed) }

    /// - Parameter locale: Picks km/h or mph until the person chooses a unit.
    init(source: any SpeedSource = LocationSpeedSource(), defaults: UserDefaults = .standard, locale: Locale = .current) {
        self.source = source
        self.defaults = defaults
        unit = defaults.string(forKey: Self.unitKey).flatMap(SpeedUnit.init(rawValue:)) ?? .preferred(for: locale)
        trip = defaults.data(forKey: Self.tripKey).flatMap { try? JSONDecoder().decode(Trip.self, from: $0) } ?? Trip()
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
            saveTrip()
        }
    }

    func resetTrip() {
        trip = Trip()
        saveTrip()
    }

    private func saveTrip() {
        if let data = try? JSONEncoder().encode(trip) {
            defaults.set(data, forKey: Self.tripKey)
        }
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
