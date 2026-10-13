import Foundation
import Testing
@testable import SbuHabits

/// The owner's Abitudini condivise against shares in memory: no iCloud needed.
struct HabitSharingTests {
    private let folder = URL.temporaryDirectory.appending(path: "HabitSharingTests-\(UUID().uuidString)")
    private let plans = PlanLog()

    private func model() -> HabitsModel {
        let model = HabitsModel(store: HabitsStore(url: folder.appending(path: "habits.json")), scheduleReminders: plans.record)
        model.add(title: "Leggere", symbol: "book")
        model.add(title: "Correre", symbol: "figure.run")
        return model
    }

    /// Sharing ready to use, iCloud signed in.
    private func sharing(_ model: HabitsModel, outbox: FakeOutbox) async -> HabitSharing {
        let sharing = HabitSharing(model: model, outbox: outbox)
        await sharing.appDidBecomeActive()
        return sharing
    }

    @Test func withoutICloudNothingCanBeShared() async {
        let model = model()
        let sharing = await sharing(model, outbox: FakeOutbox(isAvailable: false))

        #expect(sharing.isAvailable == false)
        await #expect(throws: SharingFailure.unavailable) {
            try await sharing.prepareShare(of: model.habits[0])
        }
    }

    @Test(arguments: [true, false])
    func withoutAnOutboxICloudLooksAsTold(isAvailable: Bool) {
        #expect(HabitSharing(model: model(), outbox: nil, isAvailable: isAvailable).isAvailable == isAvailable)
    }

    @Test func sharingSendsTheFirstSnapshotWithoutWhatStaysHere() async throws {
        let model = model()
        let outbox = FakeOutbox()
        let sharing = await sharing(model, outbox: outbox)
        let habit = model.habits[0]

        _ = try await sharing.prepareShare(of: habit)

        let sent = try #require(try await outbox.snapshot(of: habit.id))
        #expect(sent == SharedHabitSnapshot(habit: habit, startHour: model.startHour))
        #expect(sharing.participantCount(of: habit) == 0)
        #expect(sharing.participantCount(of: model.habits[1]) == nil)
    }

    @Test func theRowCountsThePeopleInvited() async throws {
        let model = model()
        let outbox = FakeOutbox()
        let sharing = await sharing(model, outbox: outbox)
        let habit = model.habits[0]
        _ = try await sharing.prepareShare(of: habit)
        await outbox.setParticipants(2, of: habit.id)

        await sharing.sharingDidChange(for: habit.id, stopped: false)

        #expect(sharing.participantCount(of: habit) == 2)
    }

    @Test func aChangeToASharedHabitIsSentOnce() async throws {
        let model = model()
        let outbox = FakeOutbox()
        let sharing = await sharing(model, outbox: outbox)
        _ = try await sharing.prepareShare(of: model.habits[0])

        model.markDone(model.habits[0])
        await sharing.publishChanges()
        await sharing.publishChanges()

        #expect(await outbox.publishes == 1)
        #expect(try await outbox.snapshot(of: model.habits[0].id)?.habit.count(on: model.today) == 1)
    }

    @Test func aChangeToAHabitNotSharedSendsNothing() async throws {
        let model = model()
        let outbox = FakeOutbox()
        let sharing = await sharing(model, outbox: outbox)
        _ = try await sharing.prepareShare(of: model.habits[0])

        model.markDone(model.habits[1])
        await sharing.publishChanges()

        #expect(await outbox.publishes == 0)
    }

    @Test func aNewNoteIsNotAChangePeopleSee() async throws {
        let model = model()
        let outbox = FakeOutbox()
        let sharing = await sharing(model, outbox: outbox)
        _ = try await sharing.prepareShare(of: model.habits[0])

        model.setNote("Solo per me", for: model.habits[0], on: model.today)
        await sharing.publishChanges()

        #expect(await outbox.publishes == 0)
    }

    @Test func deletingASharedHabitStopsSharingIt() async throws {
        let model = model()
        let outbox = FakeOutbox()
        let sharing = await sharing(model, outbox: outbox)
        let habit = model.habits[0]
        _ = try await sharing.prepareShare(of: habit)

        model.delete(habit)
        await sharing.publishChanges()

        #expect(await outbox.stopped == [habit.id])
        #expect(sharing.participantCount(of: habit) == nil)
    }

    @Test func aSharedHabitNotYetSyncedHereStaysShared() async throws {
        let model = model()
        let outbox = FakeOutbox()
        // Shared from another of the owner's devices, its habit not here yet.
        let elsewhere = UUID()
        await outbox.setParticipants(1, of: elsewhere)
        let sharing = await sharing(model, outbox: outbox)

        await sharing.publishChanges()

        #expect(await outbox.stopped.isEmpty)
        #expect(sharing.participants[elsewhere] == 1)
    }

    @Test func stoppingFromTheSystemScreenDeletesTheZone() async throws {
        let model = model()
        let outbox = FakeOutbox()
        let sharing = await sharing(model, outbox: outbox)
        let habit = model.habits[0]
        _ = try await sharing.prepareShare(of: habit)

        await sharing.sharingDidChange(for: habit.id, stopped: true)

        #expect(await outbox.stopped == [habit.id])
        #expect(sharing.participantCount(of: habit) == nil)
    }

    @Test func aShareStoppedElsewhereIsForgottenAtTheNextSend() async throws {
        let model = model()
        let outbox = FakeOutbox()
        let sharing = await sharing(model, outbox: outbox)
        let habit = model.habits[0]
        _ = try await sharing.prepareShare(of: habit)
        await outbox.dropShare(of: habit.id)

        model.markDone(habit)
        await sharing.publishChanges()

        #expect(sharing.participantCount(of: habit) == nil)
    }

    @Test func offlineTheChangeWaitsForTheNextTime() async throws {
        let model = model()
        let outbox = FakeOutbox()
        let sharing = await sharing(model, outbox: outbox)
        _ = try await sharing.prepareShare(of: model.habits[0])
        await outbox.setOffline(true)
        model.markDone(model.habits[0])
        await sharing.publishChanges()
        #expect(await outbox.publishes == 0)
        // Offline, what is known about the shares stays.
        #expect(sharing.participantCount(of: model.habits[0]) == 0)

        await outbox.setOffline(false)
        await sharing.appDidBecomeActive()

        #expect(await outbox.publishes == 1)
    }

    @Test func theSyncSwitchDoesNotMatter() async throws {
        let model = model()
        let outbox = FakeOutbox()
        let sync = HabitsSync(model: model, remote: nil, base: HabitsStore(url: folder.appending(path: "base.json")), preferences: nil, account: { nil })
        let sharing = await sharing(model, outbox: outbox)

        _ = try await sharing.prepareShare(of: model.habits[0])

        #expect(sync.isEnabled == false)
        #expect(sharing.participantCount(of: model.habits[0]) == 0)
    }
}
