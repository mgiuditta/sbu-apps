import Foundation

/// One message read from an export, ready to store.
nonisolated struct ParsedMessage: Equatable, Sendable {
    let sentAt: Date
    /// The author, or `nil` for a system line.
    let sender: String?
    let kind: MessageKind
    /// The message without WhatsApp's markers; several lines when the author wrote several.
    let text: String

    /// The words the author wrote; zero for media, deleted and system messages.
    var wordCount: Int {
        kind == .text ? MessageClassifier.wordCount(text) : 0
    }
}
