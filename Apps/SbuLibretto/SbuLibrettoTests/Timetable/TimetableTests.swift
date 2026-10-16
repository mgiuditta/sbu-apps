import Foundation
import Testing
@testable import SbuLibretto

struct TimetableTests {
    @Test(arguments: [(0, "00:00"), (9 * 60 + 5, "09:05"), (13 * 60, "13:00"), (23 * 60 + 59, "23:59"), (12 * 60, "12:00")])
    func timesAreWrittenInTwentyFourHours(_ minutes: Int, _ expected: String) {
        #expect(ClockTime(minutes: minutes).text == expected)
    }

    @Test(arguments: [(1_440, 0), (-30, 1_410), (1_500, 60), (-1_440, 0), (2_880 + 61, 61)])
    func minutesFoldIntoOneDay(_ minutes: Int, _ expected: Int) {
        #expect(ClockTime(minutes: minutes).minutes == expected)
    }

    @Test(arguments: ["en_US", "it_IT", "ar_SA", "ja_JP"])
    func noAMPMShiftWhateverTheLanguage(_ identifier: String) {
        // The original's reviews: an afternoon lesson saved as morning. Here 14:30 goes and comes back as 14:30.
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale(identifier: identifier)
        calendar.timeZone = TimeZone(identifier: "America/New_York") ?? .gmt
        let time = ClockTime(hour: 14, minute: 30)
        let picked = time.date(on: Date(timeIntervalSince1970: 1_790_000_000), calendar: calendar)
        #expect(ClockTime(picked, calendar: calendar) == time)
        #expect(time.hour == 14)
        #expect(time.minute == 30)
    }

    @Test func weekStartsWhereTheCalendarSays() {
        var italian = Calendar(identifier: .gregorian)
        italian.firstWeekday = 2
        #expect(LessonSlot.weekdays(calendar: italian) == [2, 3, 4, 5, 6, 7, 1])
        var american = Calendar(identifier: .gregorian)
        american.firstWeekday = 1
        #expect(LessonSlot.weekdays(calendar: american) == [1, 2, 3, 4, 5, 6, 7])
    }

    nonisolated static func slot(_ title: String, weekday: Int = 2, _ start: Int, _ end: Int) -> LessonSlot {
        LessonSlot(id: UUID(), title: title, room: "", weekday: weekday, start: ClockTime(minutes: start), end: ClockTime(minutes: end))
    }

    @Test(arguments: [
        (540, 660, 600, 720, true),   // 9-11 and 10-12
        (540, 660, 660, 720, false),  // 9-11 and 11-12: touching
        (540, 660, 480, 540, false),  // 8-9 before
        (540, 660, 560, 600, true),   // inside
        (540, 660, 480, 720, true),   // around
    ])
    func overlaps(_ start: Int, _ end: Int, _ otherStart: Int, _ otherEnd: Int, _ expected: Bool) {
        let first = Self.slot("A", start, end)
        let second = Self.slot("B", otherStart, otherEnd)
        #expect(first.overlaps(second) == expected)
        #expect(second.overlaps(first) == expected)
    }

    @Test func differentDaysNeverOverlap() {
        #expect(!Self.slot("A", weekday: 2, 540, 660).overlaps(Self.slot("B", weekday: 3, 540, 660)))
    }

    @Test func aDayIsInTimeOrder() {
        let slots = [Self.slot("Reti", 840, 960), Self.slot("Analisi", 540, 660), Self.slot("Altro", weekday: 4, 480, 540), Self.slot("Basi", 540, 600)]
        #expect(LessonSlot.day(2, in: slots).map(\.title) == ["Analisi", "Basi", "Reti"])
        #expect(LessonSlot.day(7, in: slots).isEmpty)
    }

    @Test func aLessonNeedsATitleAndAnEndAfterItsStart() {
        var draft = LessonDraft(weekday: 2)
        #expect(draft.problem == .missingTitle)
        draft.title = "  "
        #expect(draft.problem == .missingTitle)
        draft.title = "Analisi"
        #expect(draft.problem == nil)
        draft.end = draft.start
        #expect(draft.problem == .endNotAfterStart)
        draft.end = ClockTime(hour: 8, minute: 0)
        #expect(draft.problem == .endNotAfterStart)
    }

    @Test(arguments: [0, -3, 8, 100])
    func aWeekdayOutOfRangeComesBack(_ weekday: Int) {
        #expect((1...7).contains(LessonDraft(weekday: weekday).weekday))
    }

    @Test func overlapsLeaveOutTheLessonItself() {
        let id = UUID()
        var draft = LessonDraft(weekday: 2, start: ClockTime(hour: 9, minute: 0), end: ClockTime(hour: 11, minute: 0))
        draft.title = "Analisi"
        let mine = LessonSlot(id: id, title: "Analisi", room: "", weekday: 2, start: draft.start, end: draft.end)
        let other = Self.slot("Fisica", 600, 720)
        #expect(draft.overlaps(id: id, among: [mine, other]).map(\.title) == ["Fisica"])
    }
}
