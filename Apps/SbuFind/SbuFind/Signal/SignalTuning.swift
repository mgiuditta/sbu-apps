import Foundation

/// Every threshold that turns a signal into what the screen says, in one place.
///
/// The defaults are estimates from public measurements of BLE earbuds and trackers, not from
/// tests on real devices: Matteo tunes them on his iPhone with the Debug-only Taratura screen,
/// then the values he picks become the defaults here. Release builds always use `standard`.
nonisolated struct SignalTuning: Codable, Equatable, Sendable {
    /// At or below this the percentage is 0: the edge of what an iPhone hears (dBm).
    var farthestRSSI = -100.0
    /// At or above this the percentage is 100: the device is on the iPhone (dBm).
    var nearestRSSI = -40.0
    /// How much of each new reading goes into the smoothed signal: lower is steadier but slower.
    var smoothing = 0.3
    /// Where Tiepido, Caldo and Qui vicino begin, in percent.
    var warmFrom = 35
    var hotFrom = 60
    var veryCloseFrom = 80
    /// Points below a word's threshold before the word drops.
    var hysteresis = 5
    /// The "found it" moment, and the percentage below which it can happen again.
    var foundAt = 90
    var foundRearmBelow = 75
    /// Seconds of silence before the finder says "Non sentito".
    var lostAfter: TimeInterval = 3
    /// Seconds of silence before Avvisami se lo perdi, with the app open and in the background,
    /// where iOS reports devices far less often.
    var lostAlertForeground: TimeInterval = 15
    var lostAlertBackground: TimeInterval = 60

    static let standard = SignalTuning()

    /// The values in use: the tuned ones in Debug builds, the standard ones in Release.
    static var current: SignalTuning {
        #if DEBUG
        load(from: .standard)
        #else
        standard
        #endif
    }

    private static let key = "signalTuning"

    /// The tuned values saved in `defaults`, or the standard ones.
    static func load(from defaults: UserDefaults) -> SignalTuning {
        guard let data = defaults.data(forKey: key),
              let tuning = try? JSONDecoder().decode(SignalTuning.self, from: data),
              tuning.isConsistent else {
            return standard
        }
        return tuning
    }

    func save(to defaults: UserDefaults) {
        if self == .standard {
            defaults.removeObject(forKey: Self.key)
        } else if let data = try? JSONEncoder().encode(self) {
            defaults.set(data, forKey: Self.key)
        }
    }

    /// The bands in order and never empty: Tiepido above Freddo, Caldo above Tiepido, and so on.
    var isConsistent: Bool {
        farthestRSSI < nearestRSSI
            && 0 < warmFrom && warmFrom < hotFrom && hotFrom < veryCloseFrom && veryCloseFrom <= 100
            && foundRearmBelow < foundAt && foundAt <= 100
            && hysteresis >= 0 && (0...1).contains(smoothing) && smoothing > 0
            && lostAfter > 0 && lostAlertForeground > lostAfter && lostAlertBackground >= lostAlertForeground
    }
}
