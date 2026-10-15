import Foundation
import Testing
@testable import SbuChats

struct WhatsAppParserTests {
    private static let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Europe/Rome") ?? .gmt
        return calendar
    }()

    private func parse(_ url: URL, preferring order: DateOrder = .dayMonthYear) throws -> (format: String, messages: [ParsedMessage]) {
        var messages: [ParsedMessage] = []
        let parser = WhatsAppParser(calendar: Self.calendar, preferredOrder: order)
        let format = try parser.parse(ChatFile(url: url).source, progress: { _ in }) { messages.append($0) }
        return (format, messages)
    }

    private func date(_ year: Int, _ month: Int, _ day: Int, _ hour: Int, _ minute: Int, _ second: Int = 0) -> Date? {
        Self.calendar.date(from: DateComponents(year: year, month: month, day: day, hour: hour, minute: minute, second: second))
    }

    @Test func readsAnItalianIPhoneExport() throws {
        let (format, messages) = try parse(Fixture.url("ios-it-24h.txt"))
        #expect(format == "ios")
        #expect(messages.count == 13 - 2) // two continuation lines join the message before
        #expect(messages.map(\.kind) == [.system, .text, .text, .text, .text, .omittedMedia, .text, .deleted, .text, .system, .text])
        #expect(messages[1].sentAt == date(2024, 3, 14, 9, 15, 2))
        #expect(messages[4].text == "Perfetto\nanzi, porta anche il pane\ne il dolce 🎂")
        #expect(messages[4].wordCount == 9)
        #expect(messages[8].text == "Buongiorno ☀️")
        #expect(Set(messages.compactMap(\.sender)) == ["Anna Rossi", "Luca Bianchi"])
    }

    @Test func readsAnEnglishIPhoneExportWithA12HourClock() throws {
        let (_, messages) = try parse(Fixture.url("ios-en-12h.txt"), preferring: .dayMonthYear)
        #expect(messages.count == 6)
        #expect(messages[0].sentAt == date(2024, 3, 12, 21, 41, 7))
        #expect(messages[2].sentAt == date(2024, 3, 13, 0, 5, 10)) // 12:05 AM
        #expect(messages[3].sentAt == date(2024, 3, 13, 12, 30)) // 12:30 PM
        #expect(messages.map(\.kind) == [.text, .text, .omittedMedia, .media, .text, .deleted])
    }

    @Test func readsAnItalianAndroidExport() throws {
        let (format, messages) = try parse(Fixture.url("android-it-24h.txt"))
        #expect(format == "android")
        #expect(messages.map(\.kind) == [.system, .text, .text, .omittedMedia, .media, .text, .deleted])
        #expect(messages[0].sender == nil)
        #expect(messages[4].sentAt == date(2025, 1, 13, 18, 30))
        #expect(messages[5].text == "Guarda che tramonto\ne che colori")
    }

    @Test func readsAnEnglishAndroidExportWithA12HourClock() throws {
        let (_, messages) = try parse(Fixture.url("android-en-12h.txt"))
        #expect(messages.count == 5)
        #expect(messages[3].sentAt == date(2025, 1, 13, 7, 0))
        #expect(messages[4].sentAt == date(2025, 1, 13, 12, 15))
    }

    @Test func readsTheChatInsideAZip() throws {
        let (_, messages) = try parse(Fixture.url("WhatsApp Chat - Anna Rossi.zip"))
        #expect(messages.count == 11)
    }

    @Test func settlesAmbiguousDatesByChronology() throws {
        let (_, messages) = try parse(Fixture.url("ambiguous-mdy.txt"), preferring: .dayMonthYear)
        #expect(messages.last?.sentAt == date(2024, 2, 1, 10, 0))
    }

    @Test func saysWhatItFoundWhenTheFileIsNotAChat() throws {
        #expect(throws: ImportFailure.unrecognizedFormat(firstLine: "Lista della spesa")) {
            try parse(Fixture.url("not-a-chat.txt"))
        }
    }

    @Test func anEmptyFileHasNoMessages() throws {
        #expect(throws: ImportFailure.noMessages) {
            try parse(Fixture.textFile("\n\n"))
        }
    }

    @Test func readsAThousandsLinesFileInBoundedSteps() throws {
        var lines: [String] = []
        for index in 0 ..< 5000 {
            lines.append("[\(index % 28 + 1)/\(index / 28 % 12 + 1)/24, 10:\(String(format: "%02d", index % 60)):00] \(index.isMultiple(of: 2) ? "Ada" : "Bea"): messaggio \(index)")
        }
        let url = try Fixture.textFile(lines.joined(separator: "\n"))
        var count = 0
        var lastProgress = 0.0
        _ = try WhatsAppParser(calendar: Self.calendar, preferredOrder: .dayMonthYear).parse(ChatFile(url: url).source, progress: { lastProgress = $0 }) { _ in count += 1 }
        #expect(count == 5000)
        #expect(lastProgress == 1)
    }
}
