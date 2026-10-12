/// What a speed source reports: a change of access to the position, or a new fix.
nonisolated enum SpeedEvent: Equatable, Sendable {
    case access(LocationAccess)
    case sample(SpeedSample)
}
