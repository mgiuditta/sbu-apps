import Foundation
import Testing
@testable import SbuHabits

/// Sincronizza con iCloud against a copy in memory: no iCloud needed.
struct HabitsSyncTests {
    private let folder = URL.temporaryDirectory.appending(path: "HabitsSyncTests-\(UUID().uuidString)")
    private let plans = PlanLog()

    private func model(_ name: String = "habits") -> HabitsModel {
        HabitsModel(store: HabitsStore(url: folder.appending(path: "\(name).json")), scheduleReminders: plans.record)
    }

    private func sync(_ model: HabitsModel, remote: FakeRemote?, account: Data? = Data([1]), preferences: UserDefaults? = nil, base: String = "base") -> HabitsSync {
        HabitsSync(model: model, remote: remote, base: HabitsStore(url: folder.appending(path: "\(base).json")), preferences: preferences, account: { account })
    }

    @Test func itIsOffByDefaultAndNeverTouchesICloud() async {
        let remote = FakeRemote()
        let model = model()
        let sync = sync(model, remote: remote)
        model.add(title: "Leggere", symbol: "book")

        await sync.sync()

        #expect(sync.isEnabled == false)
        #expect(await remote.writes == 0)
    }

    @Test func withoutICloudItCannotBeTurnedOn() async {
        let sync = sync(model(), remote: FakeRemote(), account: nil)

        await sync.setEnabled(true)

        #expect(sync.isAvailable == false)
        #expect(sync.isEnabled == false)
    }

    @Test func turningItOnMergesBothSidesWithoutAsking() async throws {
        let model = model()
        model.add(title: "Leggere", symbol: "book")
        let other = Habit(title: "Camminare", symbol: "figure.walk", createdOn: model.today)
        let remote = FakeRemote(HabitsFile(habits: [other]))
        let sync = sync(model, remote: remote)

        await sync.setEnabled(true)

        #expect(model.habits.map(\.title).sorted() == ["Camminare", "Leggere"])
        #expect(try #require(await remote.file).habits.count == 2)
        // Saved here too, for the widget.
        #expect(try HabitsStore(url: folder.appending(path: "habits.json")).load() == model.file)
    }

    @Test func aMergeReplansTheReminders() async throws {
        let model = model()
        var other = Habit(title: "Camminare", symbol: "figure.walk", createdOn: model.today)
        _ = other.update(title: "Camminare", symbol: "figure.walk", timesPerDay: 1, schedule: .everyDay, reminders: [ReminderTime(hour: 23, minute: 59)], from: model.today)
        let sync = sync(model, remote: FakeRemote(HabitsFile(habits: [other])))
        let before = plans.plans.count

        await sync.setEnabled(true)

        #expect(plans.plans.count > before)
        #expect(plans.last?.contains { $0.habitID == other.id } == true)
    }

    @Test func twoIPhonesAgreeAfterSyncingInTurn() async throws {
        let remote = FakeRemote()
        let first = model("first")
        let second = model("second")
        let firstSync = sync(first, remote: remote, base: "firstBase")
        let secondSync = sync(second, remote: remote, base: "secondBase")
        first.add(title: "Leggere", symbol: "book")
        await firstSync.setEnabled(true)
        await secondSync.setEnabled(true)

        second.markDone(second.habits[0])
        await secondSync.sync()
        await firstSync.sync()

        #expect(first.habits[0].isDone(on: first.today))
        #expect(first.file == second.file)
    }

    @Test func aMarkTakenBackStaysTakenBackAfterSyncing() async throws {
        let remote = FakeRemote()
        let model = model()
        let sync = sync(model, remote: remote)
        model.add(title: "Leggere", symbol: "book")
        model.markDone(model.habits[0])
        await sync.setEnabled(true)

        model.undoLast(model.habits[0])
        await sync.sync()

        #expect(model.habits[0].count(on: model.today) == 0)
        #expect(try #require(await remote.file).habits[0].count(on: model.today) == 0)
    }

    @Test func aHabitDeletedOnOneIPhoneGoesFromTheOther() async throws {
        let remote = FakeRemote()
        let first = model("first")
        let second = model("second")
        let firstSync = sync(first, remote: remote, base: "firstBase")
        let secondSync = sync(second, remote: remote, base: "secondBase")
        first.add(title: "Leggere", symbol: "book")
        await firstSync.setEnabled(true)
        await secondSync.setEnabled(true)

        first.delete(first.habits[0])
        await firstSync.sync()
        second.edit(second.habits[0], title: "Leggere libri", symbol: "book", timesPerDay: 1, schedule: .everyDay)
        await secondSync.sync()

        #expect(second.habits.isEmpty)
        #expect(try #require(await remote.file).habits.isEmpty)
    }

    @Test func aCopyFromANewerAppIsNeverOverwritten() async throws {
        let newer = Data(#"{"version": 99, "habits": []}"#.utf8)
        let remote = FakeRemote()
        await remote.put(newer)
        let model = model()
        model.add(title: "Leggere", symbol: "book")
        let sync = sync(model, remote: remote)

        await sync.setEnabled(true)

        #expect(sync.isNewerOnICloud)
        #expect(await remote.data == newer)
        #expect(model.habits.count == 1)
    }

    @Test func aDamagedCopyIsReplacedByThisIPhonesHabits() async throws {
        let remote = FakeRemote()
        await remote.put(Data("not json".utf8))
        let model = model()
        model.add(title: "Leggere", symbol: "book")
        let sync = sync(model, remote: remote)

        await sync.setEnabled(true)

        #expect(try #require(await remote.file) == model.file)
    }

    @Test func conflictVersionsAreMergedThenResolved() async throws {
        let model = model()
        let today = model.today
        let remote = FakeRemote(HabitsFile(habits: [Habit(title: "Camminare", symbol: "figure.walk", createdOn: today)]))
        try await remote.addConflict(HabitsFile(habits: [Habit(title: "Nuotare", symbol: "figure.pool.swim", createdOn: today)]))
        let sync = sync(model, remote: remote)

        await sync.setEnabled(true)

        #expect(model.habits.map(\.title).sorted() == ["Camminare", "Nuotare"])
        #expect(await remote.resolved.count == 1)
        #expect(await remote.conflicts.isEmpty)
    }

    @Test func nothingIsWrittenWhenBothSidesAgree() async throws {
        let remote = FakeRemote()
        let model = model()
        model.add(title: "Leggere", symbol: "book")
        let sync = sync(model, remote: remote)
        await sync.setEnabled(true)
        let writes = await remote.writes

        await sync.sync()

        #expect(await remote.writes == writes)
    }

    @Test func turningItOffKeepsTheHabitsHere() async throws {
        let remote = FakeRemote()
        let model = model()
        model.add(title: "Leggere", symbol: "book")
        let sync = sync(model, remote: remote)
        await sync.setEnabled(true)

        await sync.setEnabled(false)
        model.add(title: "Camminare", symbol: "figure.walk")
        await sync.sync()

        #expect(model.habits.count == 2)
        #expect(try #require(await remote.file).habits.count == 1)
    }

    @Test func anotherICloudAccountTurnsItOff() async throws {
        let suite = "HabitsSyncTests-\(UUID().uuidString)"
        let preferences = try #require(UserDefaults(suiteName: suite))
        defer { preferences.removePersistentDomain(forName: suite) }
        let model = model()
        await sync(model, remote: FakeRemote(), account: Data([1]), preferences: preferences).setEnabled(true)

        let sameAccount = sync(model, remote: FakeRemote(), account: Data([1]), preferences: preferences)
        #expect(sameAccount.isEnabled)

        let otherAccount = sync(model, remote: FakeRemote(), account: Data([2]), preferences: preferences)
        #expect(otherAccount.isEnabled == false)
        #expect(preferences.bool(forKey: "syncsWithICloud") == false)
    }
}
