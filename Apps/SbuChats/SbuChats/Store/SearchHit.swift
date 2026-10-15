import Foundation

/// A message that matches a search, with the matching words marked.
nonisolated struct SearchHit: Identifiable, Hashable, Sendable {
    /// Marks the start and the end of a match inside `snippet`.
    static let matchStart: Character = "\u{1}"
    static let matchEnd: Character = "\u{2}"

    let id: Int64
    let sentAt: Date
    let sender: String
    /// The text around the match, with matches between `matchStart` and `matchEnd`.
    let snippet: String
}
