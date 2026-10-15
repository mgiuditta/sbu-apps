/// A written message's text and its author, for word and emoji counts.
nonisolated struct SenderText: Equatable, Sendable {
    let sender: String
    let text: String
}
