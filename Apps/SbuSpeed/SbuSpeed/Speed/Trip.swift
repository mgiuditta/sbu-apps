import Foundation

/// The current trip: top speed, distance and time spent moving, from the samples seen while the app is open.
/// It is saved on the iPhone and goes on across launches until the person resets it.
nonisolated struct Trip: Codable, Equatable, Sendable {
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
    /// When the trip first moved, and when it last moved: the times Salva e azzera saves with it.
    private(set) var startedAt: Date?
    private(set) var endedAt: Date?
    /// The previous fix. Not saved: after a relaunch the gap is too long to add distance anyway.
    private var last: SpeedSample?

    /// Metres per second over the time spent moving, so stops do not lower it.
    var averageSpeed: Double { movingTime > 0 ? distance / movingTime : 0 }

    var isEmpty: Bool { maxSpeed == 0 && distance == 0 }

    /// The time spent moving, in whole seconds: the clock on screen never runs ahead.
    var movingDuration: Duration { .seconds(Int(movingTime)) }

    /// The time spent moving as a clock: "1:05:20".
    func movingTimeText(locale: Locale = .autoupdatingCurrent) -> String {
        Self.clockText(movingDuration, locale: locale)
    }

    /// The time spent moving in words, for VoiceOver: "1 ora, 5 minuti e 20 secondi".
    func movingTimeSpokenText(locale: Locale = .autoupdatingCurrent) -> String {
        Self.spokenText(movingDuration, locale: locale)
    }

    /// A duration as a clock: "1:05:20".
    static func clockText(_ duration: Duration, locale: Locale = .autoupdatingCurrent) -> String {
        duration.formatted(.time(pattern: .hourMinuteSecond).locale(locale))
    }

    /// A duration in words, for VoiceOver: "1 ora, 5 minuti e 20 secondi".
    static func spokenText(_ duration: Duration, locale: Locale = .autoupdatingCurrent) -> String {
        duration.formatted(.units(allowed: [.hours, .minutes, .seconds], width: .wide).locale(locale))
    }

    init() {}

    /// A trip with fixed totals, for screenshots and previews.
    init(maxSpeed: Double, distance: Double, movingTime: TimeInterval, startedAt: Date? = nil, endedAt: Date? = nil) {
        self.maxSpeed = maxSpeed
        self.distance = distance
        self.movingTime = movingTime
        self.startedAt = startedAt
        self.endedAt = endedAt
    }

    // Trips saved by 1.0 have no times: they decode with none.
    private enum CodingKeys: String, CodingKey {
        case maxSpeed, distance, movingTime, startedAt, endedAt
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
        if startedAt == nil {
            startedAt = last.timestamp
        }
        endedAt = sample.timestamp
    }
}
