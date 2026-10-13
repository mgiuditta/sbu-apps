import Foundation

/// How long the sound takes to fade out before a timer stops it; the choices of the original.
nonisolated enum SoundTimerFade: Int, Codable, CaseIterable, Identifiable, Sendable {
    case none = 0
    case tenSeconds = 10
    case thirtySeconds = 30
    case oneMinute = 60
    case fiveMinutes = 300

    var id: Self { self }
    var duration: TimeInterval { TimeInterval(rawValue) }
}
