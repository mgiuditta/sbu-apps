/// How a key goes to the TV: a tap, or the two halves of a long press.
nonisolated enum KeyAction: Sendable, Equatable {
    case click
    case press
    case release
}
