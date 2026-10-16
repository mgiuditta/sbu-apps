/// Smooths the signal strength of one device: the median of the last readings drops the odd
/// spike, then exponential smoothing steadies what is left.
///
/// Raw readings jump by 10 dBm between two packets at the same spot, which is why Find Air's
/// percentage "jumps" and "goes up while walking away" in its reviews.
nonisolated struct SignalFilter: Equatable, Sendable {
    /// Readings in the median: about a second at the usual advertising rates.
    static let window = 5
    /// How much of each new median goes into the value: lower is steadier but slower.
    static var smoothing: Double { SignalTuning.current.smoothing }

    private var recent: [Int] = []
    /// The filtered signal in dBm; `nil` before the first reading.
    private(set) var value: Double?

    /// Takes in one valid reading and returns the filtered signal.
    @discardableResult
    mutating func add(_ rssi: Int) -> Double {
        recent.append(rssi)
        if recent.count > Self.window {
            recent.removeFirst(recent.count - Self.window)
        }
        let median = Self.median(of: recent)
        let filtered = value.map { $0 + Self.smoothing * (median - $0) } ?? median
        value = filtered
        return filtered
    }

    /// The middle reading; the mean of the two middle ones for an even count.
    static func median(of readings: [Int]) -> Double {
        let sorted = readings.sorted()
        guard !sorted.isEmpty else { return 0 }
        let middle = sorted.count / 2
        if sorted.count.isMultiple(of: 2) {
            return Double(sorted[middle - 1] + sorted[middle]) / 2
        }
        return Double(sorted[middle])
    }
}
