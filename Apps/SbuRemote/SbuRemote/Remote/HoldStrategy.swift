/// What holding a key does, as on a physical remote.
nonisolated enum HoldStrategy: Equatable, Sendable {
    /// One press and one release; the TV repeats by itself (Samsung Press/Release,
    /// Android TV START_LONG/END_LONG).
    case native
    /// The remote repeats clicks at this interval while the finger stays down (LG, Sony).
    case repeating(Duration)
    /// The key does not repeat: holding it is one tap.
    case none

    static let repeatInterval = Duration.milliseconds(180)

    init(key: RemoteKey, holdsKeysNatively: Bool) {
        if !key.repeatsWhileHeld {
            self = .none
        } else if holdsKeysNatively {
            self = .native
        } else {
            self = .repeating(Self.repeatInterval)
        }
    }
}
