import Foundation

/// What the statistics read of a message: when, who, what kind, how many words.
nonisolated struct MessageRecord: Equatable, Sendable {
    let sentAt: Date
    let sender: String?
    let kind: MessageKind
    let wordCount: Int
}
