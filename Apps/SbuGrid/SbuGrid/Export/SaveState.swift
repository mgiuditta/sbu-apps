/// Where saving to Photos is.
nonisolated enum SaveState: Equatable, Sendable {
    case idle
    case saving
    case saved
    case failed
}
