/// What makes a timer fire: a countdown or a time of day.
nonisolated enum SoundTimerTrigger: Codable, Equatable, Sendable {
    case duration(minutes: Int)
    case clock(hour: Int, minute: Int)
}
