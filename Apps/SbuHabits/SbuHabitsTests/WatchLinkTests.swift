import Foundation
import Testing
@testable import SbuHabits

struct WatchLinkTests {
    private let store = HabitsStore(url: .temporaryDirectory.appending(path: "WatchLinkTests-\(UUID().uuidString).json"))
    private let defaults: UserDefaults
    private let calendar: Calendar
    private let clock: TestClock

    init() throws {
        defaults = try #require(UserDefaults(suiteName: "WatchLinkTests-\(UUID().uuidString)"))
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = try #require(TimeZone(identifier: "Europe/Rome"))
        self.calendar = calendar
        clock = TestClock(try #require(calendar.date(from: DateComponents(year: 2026, month: 10, day: 13, hour: 18))))
    }

    /// A model with the given habits, followed by a link as at launch.
    private func link(habits titles: [String] = ["Leggere"]) -> (HabitsModel, WatchLink, FakeWatchChannel) {
        let model = HabitsModel(store: store, now: { [clock] in clock.now }, calendar: calendar, scheduleReminders: { _ in })
        for title in titles {
            model.add(title: title, symbol: "book")
        }
        let channel = FakeWatchChannel()
        let link = WatchLink(model: model, channel: channel, defaults: defaults)
        model.didUpdateForWatch = { link.publish() }
        return (model, link, channel)
    }

    private func action(_ habit: Habit, _ kind: WatchAction.Kind = .mark, on day: LogicalDay, hour: Int = 7) -> WatchAction {
        WatchAction(habitID: habit.id, day: day, hour: hour, kind: kind)
    }

    @Test func everyChangeOnTheIPhoneSendsTheGrid() throws {
        let (model, _, channel) = link()

        model.markDone(model.habits[0])

        let sent = try #require(channel.sent.last)
        #expect(sent.habits[0].isDone(on: model.today))
        #expect(sent.fullStreak == model.fullStreak)
    }

    @Test func anUnchangedGridIsNotSentAgainUnlessTheWatchAsks() {
        let (model, link, channel) = link()
        link.publish()
        let count = channel.sent.count

        model.reload()
        link.publish()
        #expect(channel.sent.count == count)

        link.handle(.refreshRequest)
        link.handle(.activated)
        #expect(channel.sent.count == count + 2)
    }

    @Test func aTapOnTheWatchIsSavedWithItsHourAndConfirmed() throws {
        let (model, link, channel) = link()
        let tap = action(model.habits[0], on: model.today, hour: 7)

        link.handle(.action(tap))

        #expect(model.habits[0].markHours[model.today] == [7])
        // Saved: the file has it, as the widget reads it.
        #expect(try store.load().habits[0].isDone(on: model.today))
        let sent = try #require(channel.sent.last)
        #expect(sent.applied == [tap.id])
        #expect(sent.habits[0].isDone(on: model.today))
    }

    @Test func theGridGoesOnceTheTapIsSavedAndConfirmed() {
        let (model, link, channel) = link()
        link.publish()
        let count = channel.sent.count

        link.handle(.action(action(model.habits[0], on: model.today)))

        // Not halfway: a grid with the mark but without the confirmation would count it twice.
        #expect(channel.sent.count == count + 1)
    }

    @Test func aTapArrivingTwiceCountsOnce() {
        let (model, link, _) = link()
        model.edit(model.habits[0], title: "Bere acqua", symbol: "drop", timesPerDay: 8, schedule: .everyDay)
        let tap = action(model.habits[0], on: model.today)

        link.handle(.action(tap))
        link.handle(.action(tap))

        #expect(model.habits[0].count(on: model.today) == 1)
    }

    @Test func aMarkThenItsUndoStayInOrder() {
        let (model, link, _) = link()
        let habit = model.habits[0]

        link.handle(.action(action(habit, .mark, on: model.today)))
        link.handle(.action(action(habit, .undo, on: model.today)))

        #expect(model.habits[0].isDone(on: model.today) == false)
    }

    @Test func aTapForAHabitDeletedMeanwhileIsConfirmedAndDropped() throws {
        let (model, link, channel) = link(habits: ["Leggere", "Camminare"])
        let gone = model.habits[1]
        model.delete(gone)
        let tap = action(gone, on: model.today)

        link.handle(.action(tap))

        #expect(model.habits.count == 1)
        #expect(try #require(channel.sent.last).applied == [tap.id])
    }

    @Test func aMarkFromTheWidgetReachesTheWatchWhenTheAppReloads() throws {
        let (model, _, channel) = link()

        _ = try MarkHabitIntent.mark(model.habits[0].id.uuidString, in: store, now: clock.now, calendar: calendar)
        model.reload()

        #expect(try #require(channel.sent.last).habits[0].isDone(on: model.today))
    }

    @Test func aNewDaySendsTheNewGrid() throws {
        let (model, _, channel) = link()
        model.markDone(model.habits[0])

        clock.advance(by: 86_400)
        model.reload()

        let sent = try #require(channel.sent.last)
        #expect(sent.today == model.today)
        #expect(sent.habits[0].isDone(on: sent.today) == false)
        #expect(sent.fullStreak == 1)
    }

    @Test func anUnreadableFileNeverWipesTheWatch() throws {
        try Data("{\"version\": 999}".utf8).write(to: store.url)
        let (model, link, channel) = link(habits: [])

        link.handle(.activated)

        #expect(model.isUnreadable)
        #expect(channel.sent.isEmpty)
    }
}
