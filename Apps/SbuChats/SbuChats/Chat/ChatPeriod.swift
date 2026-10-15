import Foundation

/// The period chosen on the chat screen and the bounds it gives.
struct ChatPeriod: Hashable {
    var option: DateRangeOption = .all
    var customStart: Date
    var customEnd: Date

    /// The whole chat, with a custom period that spans it until you change it.
    init(chat: ChatSummary?) {
        customStart = chat?.firstMessageAt ?? .now
        customEnd = chat?.lastMessageAt ?? .now
    }

    /// The first and last moment counted; `nil` sides are open.
    func bounds(for chat: ChatSummary, calendar: Calendar = .current) -> (start: Date?, end: Date?) {
        option.bounds(lastMessage: chat.lastMessageAt, customStart: customStart, customEnd: customEnd, calendar: calendar)
    }
}
