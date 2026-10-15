import Foundation

extension ChatStore {
    /// The chat's numbers between `start` and `end` (everything when `nil`), computed off the main thread.
    func statistics(chatID: Int64, from start: Date?, to end: Date?, owner: String?, calendar: Calendar = .current) throws -> ChatStatistics {
        ChatStatistics(records: try records(chatID: chatID, from: start, to: end), owner: owner, calendar: calendar)
    }

    /// The most used words and emoji between `start` and `end`.
    func terms(chatID: Int64, from start: Date?, to end: Date?) throws -> TermStatistics {
        TermStatistics(texts: try texts(chatID: chatID, from: start, to: end))
    }
}
