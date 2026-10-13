import Foundation
import Testing
@testable import SbuHabits

/// How a received Abitudine condivisa shows here: as of the owner's day, with the owner's icon.
struct SharedHabitDisplayTests {
    private let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Europe/Rome") ?? .gmt
        calendar.firstWeekday = 2
        return calendar
    }()

    private func date(hour: Int) -> Date {
        calendar.date(from: DateComponents(year: 2026, month: 10, day: 13, hour: hour)) ?? .now
    }

    /// Marked on the owner's day of 12 October.
    private func received(startHour: Int, emoji: String? = nil) -> ReceivedHabit {
        let day = LogicalDay(date(hour: 12), calendar: calendar) - 1
        var habit = Habit(title: "Correre", symbol: "figure.run", createdOn: day - 5)
        habit.mark(on: day, hour: 23)
        return ReceivedHabit(key: "k", snapshot: SharedHabitSnapshot(habit: habit, startHour: startHour), ownerEmoji: emoji)
    }

    @Test(arguments: [
        // At 02:00 on the 13th, an owner whose day starts at 4 is still on the 12th: done.
        (4, 2, true),
        (0, 2, false),
        (4, 12, false),
    ])
    func theRingFollowsTheOwnersDay(startHour: Int, hour: Int, isDone: Bool) {
        let display = SharedHabitDisplay(received(startHour: startHour), now: date(hour: hour), calendar: calendar)

        #expect(display.progress.isComplete == isDone)
        #expect(display.today == LogicalDay(date(hour: hour), startHour: startHour, calendar: calendar))
    }

    @Test(arguments: [(nil, nil), ("😎", "😎"), ("🐙", nil)] as [(String?, String?)])
    func theOwnerShowsAsTheIconPicked(picked: String?, shown: String?) {
        let display = SharedHabitDisplay(received(startHour: 0, emoji: picked), now: date(hour: 12), calendar: calendar)

        #expect(display.ownerEmoji == shown)
    }

    @Test(arguments: [(nil, nil), ("😀", "😀"), ("x", nil), ("", nil)] as [(String?, String?)])
    func onlyTheOfferedEmojiAreKept(given: String?, kept: String?) {
        #expect(OwnerEmoji.validated(given) == kept)
    }

    @Test func everyOfferedEmojiIsOneCharacter() {
        #expect(OwnerEmoji.choices.allSatisfy { $0.count == 1 })
        #expect(Set(OwnerEmoji.choices).count == OwnerEmoji.choices.count)
    }
}
