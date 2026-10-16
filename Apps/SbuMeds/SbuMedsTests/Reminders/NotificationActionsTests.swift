import Foundation
import SwiftData
import Testing
@testable import SbuMeds

/// The buttons of a notification, on a fresh in-memory store.
struct NotificationActionsTests {
    private let container: ModelContainer
    private var context: ModelContext { container.mainContext }
    private let calendar = Fixtures.calendar

    init() throws {
        container = try ModelContainer.meds(inMemory: true)
    }

    private func medicine(stock: Double? = 10) -> Medicine {
        var draft = MedicineDraft(today: Fixtures.today, calendar: calendar)
        draft.name = "Ramipril"
        draft.times = [DoseTime(hour: 11, amount: 2)]
        if let stock {
            draft.tracksStock = true
            draft.stock = stock
        }
        return Cabinet.addMedicine(draft, for: Cabinet.ensurePerson(in: context), in: context, now: Fixtures.now, calendar: calendar)
    }

    @Test func takenFromTheNotificationCountsTheScheduledAmount() {
        let medicine = medicine()
        let key = DoseKey(medicineID: medicine.id, day: Fixtures.today, minutes: 11 * 60)
        let changed = NotificationActions.apply(SystemReminderCenter.takenAction, to: [key.string], in: context, now: Fixtures.now, snoozeMinutes: 10, calendar: calendar)
        #expect(changed == 1)
        #expect(medicine.record(for: key)?.mark == .taken)
        #expect(medicine.stock == 8)
    }

    @Test func snoozeMovesTheDoseAndKeepsItToTake() {
        let medicine = medicine()
        let key = DoseKey(medicineID: medicine.id, day: Fixtures.today, minutes: 11 * 60)
        NotificationActions.apply(SystemReminderCenter.snoozeAction, to: [key.string], in: context, now: Fixtures.now, snoozeMinutes: 15, calendar: calendar)
        #expect(medicine.record(for: key)?.movedTo == Fixtures.now.addingTimeInterval(15 * 60))
        #expect(medicine.stock == 10)
        // Snoozed again from the new reminder: still allowed.
        NotificationActions.apply(SystemReminderCenter.skippedAction, to: [key.string], in: context, now: Fixtures.now, snoozeMinutes: 15, calendar: calendar)
        #expect(medicine.record(for: key)?.mark == .skipped)
    }

    @Test func aDoseMarkedInTheAppIsLeftAlone() {
        let medicine = medicine()
        let key = DoseKey(medicineID: medicine.id, day: Fixtures.today, minutes: 11 * 60)
        Cabinet.mark(key, of: medicine, as: .skipped, amount: 2, at: Fixtures.now, in: context)
        let changed = NotificationActions.apply(SystemReminderCenter.takenAction, to: [key.string], in: context, now: Fixtures.now, snoozeMinutes: 10, calendar: calendar)
        #expect(changed == 0)
        #expect(medicine.record(for: key)?.mark == .skipped)
        #expect(medicine.stock == 10)
    }

    @Test func tappingTheNotificationOrBadKeysChangeNothing() {
        let medicine = medicine()
        let key = DoseKey(medicineID: medicine.id, day: Fixtures.today, minutes: 11 * 60)
        #expect(NotificationActions.apply("com.apple.UNNotificationDefaultActionIdentifier", to: [key.string], in: context, snoozeMinutes: 10) == 0)
        #expect(NotificationActions.apply(SystemReminderCenter.takenAction, to: ["nonsense", DoseKey(medicineID: UUID(), day: Fixtures.today, minutes: 0).string], in: context, snoozeMinutes: 10) == 0)
    }
}
