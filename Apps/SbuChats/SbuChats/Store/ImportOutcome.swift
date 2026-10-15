/// What an import did.
nonisolated struct ImportOutcome: Equatable, Sendable {
    /// The chat the messages are in now.
    let chatID: Int64
    /// Messages that weren't in the app before; all of them for a new chat.
    let addedMessages: Int
    /// Whether the file was a newer (or older) export of a chat already in the app.
    let merged: Bool
    /// Everyone who wrote, most messages first.
    let senders: [String]
    /// Whether "Chi sei?" still has to be asked.
    let needsOwner: Bool
}
