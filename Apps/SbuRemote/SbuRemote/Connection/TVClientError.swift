import Foundation

/// Why talking to the TV did not work, in words the screen can show.
nonisolated enum TVClientError: Error, Equatable, Sendable {
    /// No saved credential, or the TV no longer accepts it: pair again.
    case notPaired
    /// The user pressed "Nega" on the TV, or typed a wrong code.
    case rejected
    /// The TV did not answer in time: off, asleep, or on another network.
    case unreachable
    /// The TV answered with something this protocol does not expect.
    case unexpectedReply
    /// This TV's protocol has no such command.
    case unsupported
    /// Local Network is off for Sbu Remote in Settings.
    case localNetworkDenied
}
