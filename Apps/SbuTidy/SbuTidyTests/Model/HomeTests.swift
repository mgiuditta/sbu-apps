import Foundation
import SwiftData
import Testing
@testable import SbuTidy

/// The store operations, each on a fresh in-memory container.
struct HomeTests {
    private let container: ModelContainer
    private var context: ModelContext { container.mainContext }
    private let now = Fixtures.now

    init() throws {
        container = try ModelContainer.tidy(inMemory: true)
    }

    private func rooms() throws -> [Room] {
        try context.fetch(FetchDescriptor<Room>(sortBy: [SortDescriptor(\.order)]))
    }

    @Test func aNewRoomComesWithItsBaseChoresJustDone() throws {
        let room = Home.addRoom(RoomDraft(kind: .bathroom), in: context, now: now)
        try context.save()
        #expect(room.choreList.count == RoomKind.bathroom.basePresets.count)
        #expect(room.choreList.allSatisfy { $0.lastDone == now && $0.state(at: now, calendar: Fixtures.calendar).status == .clean })
    }

    @Test func aNewRoomCanStartEmpty() {
        var draft = RoomDraft(kind: .kitchen)
        draft.addsBaseChores = false
        #expect(Home.addRoom(draft, in: context, now: now).choreList.isEmpty)
    }

    @Test func newRoomsGoLast() throws {
        for kind in [RoomKind.kitchen, .bathroom, .garage] {
            Home.addRoom(RoomDraft(kind: kind), in: context, now: now)
        }
        #expect(try rooms().map(\.order) == [0, 1, 2])
        #expect(try rooms().map(\.kind) == [.kitchen, .bathroom, .garage])
    }

    @Test func duplicateGoesRightAfterWithFreshChores() throws {
        let kitchen = Home.addRoom(RoomDraft(kind: .kitchen), in: context, now: Fixtures.daysAgo(30))
        let bathroom = Home.addRoom(RoomDraft(kind: .bathroom), in: context, now: Fixtures.daysAgo(30))
        let garage = Home.addRoom(RoomDraft(kind: .garage), in: context, now: Fixtures.daysAgo(30))
        let wc = try #require(bathroom.choreList.first)
        wc.markDone(at: Fixtures.daysAgo(3), now: now, in: context)
        wc.notes = "Anticalcare sotto il lavandino"

        let copy = Home.duplicate(bathroom, in: context, now: now)
        try context.save()

        #expect(try rooms().map(\.id) == [kitchen.id, bathroom.id, copy.id, garage.id])
        #expect(copy.name == "\(bathroom.name) 2")
        #expect(copy.choreList.count == bathroom.choreList.count)
        #expect(copy.choreList.allSatisfy { $0.lastDone == now && ($0.completions ?? []).isEmpty })
        #expect(copy.choreList.contains { $0.notes == "Anticalcare sotto il lavandino" })
        #expect(Set(copy.choreList.map(\.id)).isDisjoint(with: bathroom.choreList.map(\.id)))
    }

    @Test func duplicatingAnEmptyRoomWorks() throws {
        var draft = RoomDraft(kind: .other, name: "Soffitta")
        draft.addsBaseChores = false
        let room = Home.addRoom(draft, in: context, now: now)
        let copy = Home.duplicate(room, in: context, now: now)
        try context.save()
        #expect(copy.choreList.isEmpty)
        #expect(try rooms().count == 2)
    }

    @Test(arguments: [
        ("Bagno", [String](), "Bagno 2"),
        ("Bagno", ["Bagno 2"], "Bagno 3"),
        ("Bagno", ["Bagno 2", "Bagno 3", "Bagno 4"], "Bagno 5"),
        (String(repeating: "x", count: 40), [], String(repeating: "x", count: 36) + " 2"),
    ])
    func copyNamesNeverClash(name: String, existing: [String], expected: String) {
        let copy = Home.copyName(of: name, existing: existing)
        #expect(copy == expected)
        #expect(copy.count <= RoomDraft.maxNameLength)
    }

    @Test func movingRenumbersTheRooms() throws {
        for kind in [RoomKind.kitchen, .bathroom, .bedroom, .garage] {
            Home.addRoom(RoomDraft(kind: kind), in: context, now: now)
        }
        Home.move(try rooms(), from: IndexSet(integer: 3), to: 0)
        #expect(try rooms().map(\.kind) == [.garage, .kitchen, .bathroom, .bedroom])
        #expect(try rooms().map(\.order) == [0, 1, 2, 3])
    }

    @Test func deletingARoomDeletesItsChoresAndHistory() throws {
        let room = Home.addRoom(RoomDraft(kind: .kitchen), in: context, now: now)
        room.choreList.first?.markDone(at: now, now: now, in: context)
        try context.save()
        Home.delete(room, in: context)
        try context.save()
        #expect(try context.fetchCount(FetchDescriptor<Chore>()) == 0)
        #expect(try context.fetchCount(FetchDescriptor<Completion>()) == 0)
    }

    @Test func doneNowStartsANewCycleAndKeepsTheHistory() throws {
        let room = Home.addRoom(RoomDraft(kind: .kitchen), in: context, now: Fixtures.daysAgo(20))
        let chore = try #require(room.choreList.first)
        chore.markDone(at: Fixtures.daysAgo(10), now: now, in: context)
        chore.markDone(at: now, now: now, in: context)
        chore.markDone(at: Fixtures.daysAgo(15), now: now, in: context)
        try context.save()
        #expect(chore.lastDone == now)
        #expect(chore.history.map(\.date) == [now, Fixtures.daysAgo(10), Fixtures.daysAgo(15)])
    }

    @Test func aOneOffChoreIsGoneOnceDone() throws {
        let room = Home.addRoom(RoomDraft(kind: .other, name: "Cantina"), in: context, now: now)
        var draft = ChoreDraft(lastDone: Fixtures.daysAgo(5))
        draft.name = "Buttare il vecchio divano"
        draft.isOneOff = true
        let chore = Home.addChore(draft, to: room, in: context, now: now)
        try context.save()
        chore.markDone(at: now, now: now, in: context)
        try context.save()
        #expect(try context.fetchCount(FetchDescriptor<Chore>(predicate: #Predicate { $0.isOneOff })) == 0)
        #expect(try context.fetchCount(FetchDescriptor<Completion>()) == 0)
    }

    @Test func removingTheLatestDoneGoesBackToThePreviousOne() throws {
        let room = Home.addRoom(RoomDraft(kind: .kitchen), in: context, now: Fixtures.daysAgo(20))
        let chore = try #require(room.choreList.first)
        chore.markDone(at: Fixtures.daysAgo(10), now: now, in: context)
        chore.markDone(at: Fixtures.daysAgo(2), now: now, in: context)
        try context.save()

        let latest = try #require(chore.history.first)
        chore.remove(latest, in: context)
        try context.save()
        #expect(chore.lastDone == Fixtures.daysAgo(10))

        let only = try #require(chore.history.first)
        chore.remove(only, in: context)
        try context.save()
        #expect(chore.lastDone == Fixtures.daysAgo(20))
        #expect(chore.history.isEmpty)
    }

    @Test func pauseAndResumeThroughTheModel() throws {
        let room = Home.addRoom(RoomDraft(kind: .garden), in: context, now: Fixtures.daysAgo(10))
        let chore = try #require(room.choreList.first)
        chore.pause(at: Fixtures.daysAgo(6))
        #expect(chore.state(at: now, calendar: Fixtures.calendar).status == .paused)
        chore.resume(at: Fixtures.daysAgo(1))
        try context.save()
        #expect(chore.clock.elapsed(at: now) == 5 * 86_400)
    }

    @Test func invalidDraftsChangeNothing() throws {
        let room = Home.addRoom(RoomDraft(kind: .kitchen), in: context, now: now)
        let chore = try #require(room.choreList.first)
        let name = chore.name
        var draft = ChoreDraft()
        draft.name = "   "
        Home.update(chore, with: draft)
        Home.update(room, with: RoomDraft(kind: .garage, name: ""))
        #expect(chore.name == name)
        #expect(room.kind == .kitchen)
    }

    @Test func updateStoresTheCleanDraft() throws {
        let room = Home.addRoom(RoomDraft(kind: .kitchen), in: context, now: now)
        let chore = try #require(room.choreList.first)
        var draft = ChoreDraft()
        draft.name = "  Forno  "
        draft.frequencyValue = 99
        draft.frequencyUnit = .month
        draft.effort = .heavy
        draft.notes = " Con il bicarbonato "
        Home.update(chore, with: draft)
        try context.save()
        #expect(chore.name == "Forno")
        #expect(chore.frequency == Frequency(24, .month))
        #expect(chore.effort == .heavy)
        #expect(chore.notes == "Con il bicarbonato")
    }

    @Test func garbageInTheStoreStillReadsSafely() throws {
        let room = Home.addRoom(RoomDraft(kind: .kitchen), in: context, now: now)
        let chore = try #require(room.choreList.first)
        chore.frequencyValue = -40
        chore.frequencyUnitRaw = "fortnight"
        chore.effortRaw = 99
        room.kindRaw = "attic"
        #expect(chore.frequency == Frequency(1, .week))
        #expect(chore.effort == .heavy)
        #expect(room.kind == .other)
    }

    @Test func sampleHomeHasSomethingToDoAndSomethingPaused() throws {
        SampleHome.insert(into: context, now: now, calendar: Fixtures.calendar)
        try context.save()
        let chores = try context.fetch(FetchDescriptor<Chore>())
        let states = chores.map { $0.state(at: now, calendar: Fixtures.calendar).status }
        #expect(states.contains(.overdue))
        #expect(states.contains(.clean))
        #expect(states.contains(.paused))
        #expect(try rooms().count == 4)
    }
}
