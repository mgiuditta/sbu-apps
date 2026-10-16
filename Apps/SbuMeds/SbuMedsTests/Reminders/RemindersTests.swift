import Foundation
import SwiftData
import Testing
@testable import SbuMeds

struct RemindersTests {
    private let defaults: UserDefaults

    init() {
        let suite = "meds.tests.\(UUID().uuidString)"
        defaults = UserDefaults(suiteName: suite) ?? .standard
        defaults.removePersistentDomain(forName: suite)
    }

    @Test func onByDefaultWithRepeatsEveryFifteenMinutes() {
        let reminders = Reminders(defaults: defaults, center: RecordingCenter())
        #expect(reminders.isOn)
        #expect(reminders.repeatMinutes == 15)
        #expect(reminders.snoozeMinutes == 10)
    }

    @Test func choicesOutsideTheListFallBack() {
        defaults.set(7, forKey: "reminders.repeatMinutes")
        defaults.set(0, forKey: "reminders.snoozeMinutes")
        let reminders = Reminders(defaults: defaults, center: RecordingCenter())
        #expect(reminders.repeatMinutes == Reminders.defaultRepeatMinutes)
        #expect(reminders.snoozeMinutes == Reminders.defaultSnoozeMinutes)
    }

    @Test func permissionIsAskedOnlyOnceAMedicineHasATime() async {
        let center = RecordingCenter()
        let reminders = Reminders(defaults: defaults, center: center)
        let asNeeded = MedicineSnapshot(name: "Antidolorifico", schedule: Schedule(frequency: .asNeeded, start: Fixtures.today))
        await reminders.reschedule([asNeeded], now: Fixtures.now, calendar: Fixtures.calendar)
        #expect(center.requests == 0)
        await reminders.reschedule([Fixtures.medicine(times: [DoseTime(hour: 20)])], now: Fixtures.now, calendar: Fixtures.calendar)
        #expect(center.requests == 1)
        #expect(center.replaced.last?.isEmpty == false)
    }

    @Test func turnedOffOrDeniedClearsEverything() async {
        let center = RecordingCenter()
        center.answer = .denied
        let reminders = Reminders(defaults: defaults, center: center)
        let medicine = Fixtures.medicine(times: [DoseTime(hour: 20)])
        await reminders.reschedule([medicine], now: Fixtures.now, calendar: Fixtures.calendar)
        #expect(center.replaced.last == [])
        #expect(reminders.access == .denied)

        center.granted = .allowed
        reminders.isOn = false
        await reminders.reschedule([medicine], now: Fixtures.now, calendar: Fixtures.calendar)
        #expect(center.replaced.last == [])
    }

    @Test func deliveredRemindersOfMarkedDosesAreCleared() async {
        let center = RecordingCenter()
        center.granted = .allowed
        let reminders = Reminders(defaults: defaults, center: center)
        let id = UUID()
        let taken = DoseRecordSnapshot(key: DoseKey(medicineID: id, day: Fixtures.today, minutes: 8 * 60), mark: .taken)
        let medicine = Fixtures.medicine(id: id, times: [DoseTime(hour: 8), DoseTime(hour: 11)], records: [taken])
        await reminders.reschedule([medicine], now: Fixtures.now, calendar: Fixtures.calendar)
        let still = center.stillToTake.last ?? []
        #expect(still.contains(DoseKey(medicineID: id, day: Fixtures.today, minutes: 11 * 60).string))
        #expect(!still.contains(DoseKey(medicineID: id, day: Fixtures.today, minutes: 8 * 60).string))
    }

    /// Twenty-four doses a day fill iOS's 64 slots in under three days: Today asks to open the app.
    @Test func aCrowdedDayAsksToOpenTheAppAndAQuietOneDoesNot() async {
        let center = RecordingCenter()
        center.granted = .allowed
        let reminders = Reminders(defaults: defaults, center: center)
        let hourly = Fixtures.medicine(times: (0..<24).map { DoseTime(hour: $0) })
        await reminders.reschedule([hourly], now: Fixtures.now, calendar: Fixtures.calendar)
        #expect(center.replaced.last?.count == ReminderPlan.limit)
        #expect(reminders.openEveryDays == 2)

        await reminders.reschedule([Fixtures.medicine(times: [DoseTime(hour: 20)])], now: Fixtures.now, calendar: Fixtures.calendar)
        #expect(reminders.openEveryDays == nil)
    }
}
