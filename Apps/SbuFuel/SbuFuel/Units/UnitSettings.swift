import Foundation
import Observation

/// The units you picked in Settings, or the phone's region until you pick one.
@Observable
final class UnitSettings {
    private enum Key {
        static let consumption = "units.consumption"
        static let volume = "units.volume"
    }

    var consumption: ConsumptionUnit {
        didSet { defaults.set(consumption.rawValue, forKey: Key.consumption) }
    }
    var volume: VolumeUnit {
        didSet { defaults.set(volume.rawValue, forKey: Key.volume) }
    }

    @ObservationIgnored private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard, locale: Locale = .current) {
        self.defaults = defaults
        consumption = defaults.string(forKey: Key.consumption).flatMap(ConsumptionUnit.init) ?? .preferred(for: locale)
        volume = defaults.string(forKey: Key.volume).flatMap(VolumeUnit.init) ?? .preferred(for: locale)
    }
}
