/// Whether a group holds copies of one picture or shots that look alike.
nonisolated enum GroupKind: String, CaseIterable, Hashable, Sendable {
    /// The same picture, saved more than once: anywhere in the library.
    case duplicate
    /// Shots taken close in time that look alike: bursts, retakes.
    case similar
}
