import Foundation

/// A chat in the list: its name, size and the span of its messages.
nonisolated struct ChatSummary: Identifiable, Hashable, Sendable {
    let id: Int64
    let title: String
    /// Which sender is you, if you said so; `nil` also when you chose none of them.
    let owner: String?
    /// Whether you already answered "Chi sei?" for this chat.
    let ownerChosen: Bool
    let firstMessageAt: Date
    let lastMessageAt: Date
    let messageCount: Int
    /// Whether the last export came with its media files.
    let hasMedia: Bool
    /// `ios` or `android`.
    let sourceFormat: String
}
