import Foundation

/// The current trip: top speed, distance and time spent moving, from the samples seen while the app is open.
nonisolated struct Trip: Equatable, Sendable {
    /// Speeds less certain than this (m/s) do not count as the top speed: they are GPS spikes.
    static let maxSpeedAccuracy = 2.5
    /// Positions less certain than this (metres) do not add distance.
    static let maxHorizontalAccuracy = 30.0
    /// Below this speed (m/s) the position only drifts: no distance, no moving time.
    static let movingSpeed = 0.5
    /// A longer gap (seconds) between fixes means the app was away or the signal lost: no distance across it.
    static let maxGap: TimeInterval = 10

    /// Metres per second.
    private(set) var maxSpeed = 0.0
    /// Metres.
    private(set) var distance = 0.0
    /// Seconds.
    private(set) var movingTime: TimeInterval = 0
    private var last: SpeedSample?

    /// Metres per second over the time spent moving, so stops do not lower it.
    var averageSpeed: Double { movingTime > 0 ? distance / movingTime : 0 }

    var isEmpty: Bool { maxSpeed == 0 && distance == 0 }

    init() {}

    /// A trip with fixed totals, for screenshots and previews.
    init(maxSpeed: Double, distance: Double, movingTime: TimeInterval) {
        self.maxSpeed = maxSpeed
        self.distance = distance
        self.movingTime = movingTime
    }

    mutating func record(_ sample: SpeedSample) {
        if sample.hasValidSpeed, sample.speedAccuracy <= Self.maxSpeedAccuracy {
            maxSpeed = max(maxSpeed, sample.speed)
        }

        guard sample.hasValidPosition, sample.horizontalAccuracy <= Self.maxHorizontalAccuracy else { return }
        defer { last = sample }
        guard let last else { return }

        let interval = sample.timestamp.timeIntervalSince(last.timestamp)
        guard interval > 0, interval <= Self.maxGap, sample.hasValidSpeed, sample.speed >= Self.movingSpeed else { return }
        distance += sample.distance(from: last)
        movingTime += interval
    }
}
