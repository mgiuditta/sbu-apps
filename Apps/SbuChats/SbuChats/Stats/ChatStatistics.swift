import Foundation

/// Everything the chat screen and the activity charts show, in one pass over the messages.
///
/// A conversation starts after six hours without messages: whoever writes first starts it, whoever
/// wrote last before the silence ended it. A reply is the first message after someone else's; its
/// time counts only within 24 hours, so a chat left for days doesn't make anyone look slow.
nonisolated struct ChatStatistics: Equatable, Sendable {
    static let conversationGap: TimeInterval = 6 * 60 * 60
    static let replyLimit: TimeInterval = 24 * 60 * 60

    /// Messages sent, system lines excluded.
    let totalMessages: Int
    let firstMessageAt: Date?
    let lastMessageAt: Date?
    /// Everyone who wrote: you first, then by messages.
    let senders: [SenderStatistics]
    /// Days with at least one message.
    let activeDays: Int
    /// The most consecutive days with at least one message.
    let longestStreak: Int
    let conversations: Int
    /// Messages per slot and series, for each chart.
    let activity: [ActivityAxis: [ActivityPoint]]

    /// An empty chat or range.
    static let empty = ChatStatistics(records: [], owner: nil, calendar: .current)

    /// - Parameters:
    ///   - records: The messages, oldest first.
    ///   - owner: The sender who is you, if known.
    init(records: [MessageRecord], owner: String?, calendar: Calendar) {
        var reader = CalendarDay.Reader(calendar: calendar)
        var tallies: [String: Tally] = [:]
        var order: [String] = []
        var chatDays = Set<Int>()
        var activityCounts: [ActivityAxis: [Slot: Int]] = [:]
        var conversations = 0
        var total = 0
        var first: Date?
        var last: (sender: String, at: Date)?

        for record in records where record.kind.isMessage {
            guard let sender = record.sender else { continue }
            total += 1
            first = first ?? record.sentAt
            if tallies[sender] == nil {
                tallies[sender] = Tally()
                order.append(sender)
            }
            let day = reader.day(of: record.sentAt)
            chatDays.insert(day.dayNumber)

            tallies[sender]?.messages += 1
            tallies[sender]?.words += record.wordCount
            if record.kind.isMedia { tallies[sender]?.media += 1 }
            tallies[sender]?.days.insert(day.dayNumber)

            if let previous = last {
                let gap = record.sentAt.timeIntervalSince(previous.at)
                if gap >= Self.conversationGap {
                    conversations += 1
                    tallies[previous.sender]?.ended += 1
                    tallies[sender]?.started += 1
                }
                if previous.sender != sender, gap <= Self.replyLimit {
                    tallies[sender]?.replies.append(max(gap, 0))
                }
            } else {
                conversations = 1
                tallies[sender]?.started += 1
            }
            last = (sender, record.sentAt)

            let series: ActivitySeries = owner == nil ? .everyone : (sender == owner ? .you : .others)
            activityCounts[.hour, default: [:]][Slot(slot: day.hour, series: series), default: 0] += 1
            activityCounts[.weekday, default: [:]][Slot(slot: day.weekday, series: series), default: 0] += 1
            activityCounts[.month, default: [:]][Slot(slot: day.year * 12 + day.month - 1, series: series), default: 0] += 1
            activityCounts[.year, default: [:]][Slot(slot: day.year, series: series), default: 0] += 1
        }
        if let last { tallies[last.sender]?.ended += 1 }

        totalMessages = total
        firstMessageAt = first
        lastMessageAt = last?.at
        activeDays = chatDays.count
        longestStreak = Streak.longest(in: chatDays)
        self.conversations = conversations
        activity = activityCounts.mapValues { counts in
            counts.map { ActivityPoint(slot: $0.key.slot, series: $0.key.series, count: $0.value) }
                .sorted { ($0.slot, $0.series.rawValue) < ($1.slot, $1.series.rawValue) }
        }
        senders = order.compactMap { name -> SenderStatistics? in
            guard let tally = tallies[name] else { return nil }
            let replies = tally.replies.sorted()
            return SenderStatistics(
                name: name,
                isOwner: name == owner,
                messages: tally.messages,
                words: tally.words,
                media: tally.media,
                conversationsStarted: tally.started,
                conversationsEnded: tally.ended,
                medianReply: Self.median(of: replies),
                averageReply: replies.isEmpty ? nil : replies.reduce(0, +) / Double(replies.count),
                replyCount: replies.count,
                longestStreak: Streak.longest(in: tally.days),
                share: total == 0 ? 0 : Double(tally.messages) / Double(total)
            )
        }
        .sorted { lhs, rhs in
            if lhs.isOwner != rhs.isOwner { return lhs.isOwner }
            if lhs.messages != rhs.messages { return lhs.messages > rhs.messages }
            return lhs.name < rhs.name
        }
    }

    /// The middle value of sorted numbers; the mean of the two middle ones for an even count.
    static func median(of sorted: [TimeInterval]) -> TimeInterval? {
        guard !sorted.isEmpty else { return nil }
        let middle = sorted.count / 2
        return sorted.count.isMultiple(of: 2) ? (sorted[middle - 1] + sorted[middle]) / 2 : sorted[middle]
    }

    private struct Tally {
        var messages = 0
        var words = 0
        var media = 0
        var started = 0
        var ended = 0
        var replies: [TimeInterval] = []
        var days = Set<Int>()
    }

    private struct Slot: Hashable {
        let slot: Int
        let series: ActivitySeries
    }
}
