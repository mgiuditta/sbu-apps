import Foundation

extension ChatSummary {
    /// A chat for previews.
    static let preview = ChatSummary(
        id: 1,
        title: "Chat di esempio",
        owner: "Giulia",
        ownerChosen: true,
        firstMessageAt: .now.addingTimeInterval(-400 * 86400),
        lastMessageAt: .now.addingTimeInterval(-86400),
        messageCount: 4_218,
        hasMedia: false,
        sourceFormat: "ios"
    )
}
