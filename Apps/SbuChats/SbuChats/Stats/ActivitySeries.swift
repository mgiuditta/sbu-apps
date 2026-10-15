/// Whose messages a bar of the activity charts counts.
nonisolated enum ActivitySeries: String, CaseIterable, Sendable {
    /// Your messages, when you said who you are.
    case you
    /// Everyone else's.
    case others
    /// Everyone's, when the chat doesn't know who you are.
    case everyone
}
