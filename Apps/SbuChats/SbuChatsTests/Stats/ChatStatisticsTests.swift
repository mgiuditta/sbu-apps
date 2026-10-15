import Foundation
import Testing
@testable import SbuChats

struct ChatStatisticsTests {
    private static let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Europe/Rome") ?? .gmt
        return calendar
    }()

    /// 1 March 2024, 00:00 in Rome, plus `minutes`.
    private func at(day: Int = 1, _ hour: Int, _ minute: Int = 0) -> Date {
        let components = DateComponents(year: 2024, month: 3, day: day, hour: hour, minute: minute)
        return Self.calendar.date(from: components) ?? .distantPast
    }

    private func record(_ sender: String?, _ date: Date, _ kind: MessageKind = .text, words: Int = 1) -> MessageRecord {
        MessageRecord(sentAt: date, sender: sender, kind: kind, wordCount: words)
    }

    private func statistics(_ records: [MessageRecord], owner: String? = "Anna") -> ChatStatistics {
        ChatStatistics(records: records, owner: owner, calendar: Self.calendar)
    }

    @Test func countsMessagesWordsAndMediaPerPerson() {
        let stats = statistics([
            record(nil, at(9), .system, words: 0),
            record("Luca", at(9, 1), words: 4),
            record("Anna", at(9, 2), words: 2),
            record("Anna", at(9, 3), .omittedMedia, words: 0),
            record("Anna", at(9, 4), .deleted, words: 0),
        ])
        #expect(stats.totalMessages == 4)
        #expect(stats.senders.map(\.name) == ["Anna", "Luca"]) // you first
        let anna = stats.senders[0]
        #expect(anna.isOwner)
        #expect(anna.messages == 3)
        #expect(anna.words == 2)
        #expect(anna.media == 1)
        #expect(anna.share == 0.75)
        #expect(stats.senders[1].words == 4)
    }

    @Test func repliesAreMeasuredFromTheOtherPersonsLastMessage() throws {
        let stats = statistics([
            record("Anna", at(9)),
            record("Anna", at(9, 10)),
            record("Luca", at(9, 15)), // 5 minutes after Anna's last
            record("Anna", at(10, 15)), // 1 hour
            record("Luca", at(10, 16)), // 1 minute
            record("Anna", at(day: 3, 10, 30)), // more than 24 hours: not a reply time
        ])
        let anna = try #require(stats.senders.first { $0.name == "Anna" })
        let luca = try #require(stats.senders.first { $0.name == "Luca" })
        #expect(luca.replyCount == 2)
        #expect(luca.medianReply == 180) // (5 + 1) / 2 minutes
        #expect(luca.averageReply == 180)
        #expect(anna.replyCount == 1)
        #expect(anna.medianReply == 3600)
    }

    @Test func conversationsBreakAfterSixHoursOfSilence() throws {
        let stats = statistics([
            record("Anna", at(9)),
            record("Luca", at(9, 5)),
            record("Luca", at(20)), // 11 hours later: Luca ended the first, starts the second
            record("Anna", at(20, 1)),
            record("Anna", at(day: 2, 2, 2)), // 6 hours and 1 minute later
        ])
        #expect(stats.conversations == 3)
        let anna = try #require(stats.senders.first { $0.name == "Anna" })
        let luca = try #require(stats.senders.first { $0.name == "Luca" })
        #expect(anna.conversationsStarted == 2)
        #expect(luca.conversationsStarted == 1)
        #expect(luca.conversationsEnded == 1)
        #expect(anna.conversationsEnded == 2) // the second and the last
    }

    @Test func streaksCountConsecutiveDaysAcrossMonths() throws {
        var records: [MessageRecord] = []
        for day in [27, 28, 29, 30, 31] {
            records.append(record("Anna", Self.calendar.date(from: DateComponents(year: 2024, month: 1, day: day, hour: 12)) ?? .distantPast))
        }
        records.append(record("Anna", Self.calendar.date(from: DateComponents(year: 2024, month: 2, day: 1, hour: 12)) ?? .distantPast))
        records.append(record("Luca", Self.calendar.date(from: DateComponents(year: 2024, month: 2, day: 5, hour: 12)) ?? .distantPast))
        let stats = statistics(records)
        #expect(stats.longestStreak == 6)
        #expect(stats.activeDays == 7)
        #expect(stats.senders.first { $0.name == "Anna" }?.longestStreak == 6)
        #expect(stats.senders.first { $0.name == "Luca" }?.longestStreak == 1)
    }

    @Test func activitySplitsYouFromTheOthers() {
        let stats = statistics([record("Anna", at(9)), record("Luca", at(9, 30)), record("Luca", at(day: 2, 21))])
        let hours = stats.activity[.hour] ?? []
        #expect(hours.contains(ActivityPoint(slot: 9, series: .you, count: 1)))
        #expect(hours.contains(ActivityPoint(slot: 9, series: .others, count: 1)))
        #expect(hours.contains(ActivityPoint(slot: 21, series: .others, count: 1)))
        // 1 March 2024 was a Friday (weekday 6), 2 March a Saturday (7).
        #expect(stats.activity[.weekday]?.contains(ActivityPoint(slot: 6, series: .others, count: 1)) == true)
        #expect(stats.activity[.month] == [ActivityPoint(slot: 2024 * 12 + 2, series: .others, count: 2), ActivityPoint(slot: 2024 * 12 + 2, series: .you, count: 1)])
        #expect(stats.activity[.year]?.map(\.count).reduce(0, +) == 3)
    }

    @Test func withoutAnOwnerEveryoneIsOneSeries() {
        let stats = statistics([record("Anna", at(9)), record("Luca", at(10))], owner: nil)
        #expect(stats.activity[.hour]?.allSatisfy { $0.series == .everyone } == true)
        #expect(stats.senders.allSatisfy { !$0.isOwner })
    }

    @Test func anEmptyRangeHasNoNumbers() {
        let stats = statistics([])
        #expect(stats.totalMessages == 0)
        #expect(stats.senders.isEmpty)
        #expect(stats.firstMessageAt == nil)
        #expect(stats.conversations == 0)
    }

    @Test(arguments: [([], nil), ([5.0], 5.0), ([1.0, 3], 2.0), ([1.0, 2, 9], 2.0)] as [([Double], Double?)])
    func median(values: [Double], expected: Double?) {
        #expect(ChatStatistics.median(of: values) == expected)
    }

    @Test func dayNumbersAreConsecutiveAcrossYears() {
        let last = CalendarDay(year: 2023, month: 12, day: 31, hour: 0, weekday: 1)
        let first = CalendarDay(year: 2024, month: 1, day: 1, hour: 0, weekday: 2)
        #expect(first.dayNumber - last.dayNumber == 1)
        let leap = CalendarDay(year: 2024, month: 3, day: 1, hour: 0, weekday: 6)
        let february = CalendarDay(year: 2024, month: 2, day: 29, hour: 0, weekday: 5)
        #expect(leap.dayNumber - february.dayNumber == 1)
    }
}
