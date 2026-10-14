import Foundation
import Testing
@testable import SbuScanner

struct CalendarEventTests {
    private let rome = TimeZone(identifier: "Europe/Rome")!

    @Test func utcTimes() throws {
        let event = try #require(CalendarEvent(code: "BEGIN:VEVENT\nSUMMARY:Cena\\, da Anna\nDTSTART:20261020T190000Z\nDTEND:20261020T210000Z\nLOCATION:Milano\nEND:VEVENT", timeZone: rome))
        #expect(event.title == "Cena, da Anna")
        #expect(event.start == Date(timeIntervalSince1970: 1_792_522_800))
        #expect(event.end == Date(timeIntervalSince1970: 1_792_530_000))
        #expect(event.location == "Milano")
        #expect(!event.isAllDay)
    }

    @Test func localTimesFollowTheGivenTimeZone() throws {
        let event = try #require(CalendarEvent(code: "BEGIN:VEVENT\nDTSTART;TZID=Europe/Rome:20261020T210000\nEND:VEVENT", timeZone: rome))
        // 21:00 in Rome on 20 October 2026 (CEST, UTC+2) is 19:00 UTC.
        #expect(event.start == Date(timeIntervalSince1970: 1_792_522_800))
    }

    @Test func allDay() throws {
        let event = try #require(CalendarEvent(code: "BEGIN:VCALENDAR\nBEGIN:VEVENT\nDTSTART;VALUE=DATE:20261225\nSUMMARY:Natale\nEND:VEVENT\nEND:VCALENDAR"))
        #expect(event.isAllDay)
        #expect(event.title == "Natale")
    }

    @Test func noStartIsNotAnEvent() {
        #expect(CalendarEvent(code: "BEGIN:VEVENT\nSUMMARY:Cena\nEND:VEVENT") == nil)
    }

    @Test func roundTrip() throws {
        let start = Date(timeIntervalSince1970: 1_792_522_800)
        let event = CalendarEvent(title: "Riunione; sala 2", start: start, end: start.addingTimeInterval(3_600), location: "Via Roma, 1", notes: "Porta\ni fogli")
        #expect(CalendarEvent(code: event.code) == event)
    }
}
