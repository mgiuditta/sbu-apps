import Foundation

/// One person's numbers in a chat.
nonisolated struct SenderStatistics: Identifiable, Equatable, Sendable {
    var id: String { name }

    let name: String
    /// Whether this is you.
    let isOwner: Bool
    let messages: Int
    let words: Int
    /// Photos, videos, audio, stickers and documents, exported or omitted.
    let media: Int
    /// Conversations this person opened after a silence.
    let conversationsStarted: Int
    /// Conversations this person had the last word in.
    let conversationsEnded: Int
    /// The typical time this person took to answer, or `nil` without answers.
    let medianReply: TimeInterval?
    let averageReply: TimeInterval?
    /// How many answers the reply times are measured on.
    let replyCount: Int
    /// The most consecutive days this person wrote on.
    let longestStreak: Int
    /// This person's share of all messages, from 0 to 1.
    let share: Double
}
