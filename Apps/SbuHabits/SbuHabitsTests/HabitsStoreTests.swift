import Foundation
import Testing
@testable import SbuHabits

struct HabitsStoreTests {
    private let store = HabitsStore(url: .temporaryDirectory.appending(path: "HabitsStoreTests-\(UUID().uuidString)/habits.json"))

    @Test func aMissingFileLoadsAsNoHabits() throws {
        #expect(try store.load() == HabitsFile())
    }

    @Test func savedHabitsLoadBack() throws {
        var habit = Habit(title: "Leggere", symbol: "book", createdOn: LogicalDay(ordinal: 20_000))
        habit.log[LogicalDay(ordinal: 20_001)] = 1
        let file = HabitsFile(habits: [habit])

        try store.save(file)

        #expect(try store.load() == file)
    }

    @Test func aFileFromANewerVersionIsNeverOverwritten() throws {
        let newer = Data(#"{"version": 99, "habits": [], "somethingNew": true}"#.utf8)
        try FileManager.default.createDirectory(at: store.url.deletingLastPathComponent(), withIntermediateDirectories: true)
        try newer.write(to: store.url)

        #expect(throws: HabitsStore.Failure.unknownVersion(99)) { try store.load() }
        #expect(throws: HabitsStore.Failure.unknownVersion(99)) { try store.save(HabitsFile()) }
        #expect(try Data(contentsOf: store.url) == newer)
    }
}
