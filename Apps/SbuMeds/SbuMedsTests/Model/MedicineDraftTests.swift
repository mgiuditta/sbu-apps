import Foundation
import Testing
import UIKit
@testable import SbuMeds

struct MedicineDraftTests {
    private let calendar = Fixtures.calendar

    private func draft() -> MedicineDraft {
        var draft = MedicineDraft(today: Fixtures.today, calendar: calendar)
        draft.name = "  Ramipril  "
        return draft
    }

    @Test func aNameIsEnoughForADailyDoseAtEight() {
        let draft = draft()
        #expect(draft.isValid)
        #expect(draft.cleanName == "Ramipril")
        #expect(draft.schedule.times == [DoseTime(hour: 8)])
        #expect(draft.schedule.frequency == .daily)
    }

    @Test func problemsAreNamed() {
        var draft = draft()
        draft.name = "   "
        #expect(draft.problem == .noName)
        draft.name = "Ramipril"
        draft.frequency = .weekdays
        draft.weekdays = []
        #expect(draft.problem == .noWeekdays)
        draft.frequency = .daily
        draft.times = []
        #expect(draft.problem == .noTimes)
        draft.frequency = .asNeeded
        #expect(draft.problem == nil)
        draft.hasEnd = true
        draft.end = Fixtures.day(-1)
        #expect(draft.problem == .endBeforeStart)
    }

    @Test func addedTimesComeAnHourLaterAndNeverClash() {
        var draft = draft()
        draft.addTime()
        draft.addTime()
        #expect(draft.times.map(\.hour) == [8, 9, 10])
        draft.times = [DoseTime(hour: 23, minute: 30)]
        draft.addTime()
        #expect(draft.times.count == 2)
        #expect(Set(draft.times.map(\.minutes)).count == 2)
    }

    @Test func theLastTimeCannotBeRemoved() {
        var draft = draft()
        draft.removeTime(at: 0)
        #expect(draft.times.count == 1)
    }

    @Test func everyNHoursKeepsOnlyTheFirstTimeAndShowsTheRest() {
        var draft = draft()
        draft.frequency = .everyHours
        draft.everyHours = 6
        draft.times = [DoseTime(hour: 7), DoseTime(hour: 22)]
        #expect(draft.schedule.times == [DoseTime(hour: 7)])
        #expect(draft.shownTimes.map(\.hour) == [7, 13, 19])
    }

    @Test func weekdaysAreSavedOnlyForThatFrequency() {
        var draft = draft()
        draft.weekdays = [2, 4]
        #expect(draft.schedule.weekdays.isEmpty)
        draft.frequency = .weekdays
        #expect(draft.schedule.weekdays == [2, 4])
    }

    @Test func aSavedMedicineReopensTheSame() {
        var original = draft()
        original.frequency = .cycle
        original.cycleOn = 24
        original.cycleOff = 4
        original.times = [DoseTime(hour: 21, amount: 1)]
        original.hasEnd = true
        original.end = Fixtures.day(90)
        original.tracksStock = true
        original.stock = 28
        original.refillThreshold = 5
        let snapshot = MedicineSnapshot(name: original.cleanName, form: original.form, schedule: original.schedule, stock: original.cleanStock, refillThreshold: original.cleanThreshold)
        let reopened = MedicineDraft(medicine: snapshot, calendar: calendar)
        #expect(reopened.schedule == original.schedule)
        #expect(reopened.tracksStock && reopened.stock == 28 && reopened.refillThreshold == 5)
    }

    @Test func stockIsSavedOnlyWhenCounted() {
        var draft = draft()
        draft.stock = 20
        #expect(draft.cleanStock == nil)
        draft.tracksStock = true
        draft.stock = -4
        #expect(draft.cleanStock == 0)
    }

    /// The unit is singular for exactly one, plural otherwise, in whatever language the app runs.
    @Test(arguments: [
        (MedicineForm.tablet, 1.0, "1 "),
        (.tablet, 2, "2 "),
        (.tablet, 0.5, "0,5 "),
        (.liquid, 2.5, "2,5 "),
        (.drops, 10, "10 "),
    ])
    func amountsReadNaturally(form: MedicineForm, amount: Double, prefix: String) {
        let text = form.amountText(amount, locale: Locale(identifier: "it_IT"))
        #expect(text == prefix + form.unit(for: amount))
        #expect(form.unit(for: amount) == form.unit(for: amount == 1 ? 1 : 3))
    }

    @Test func singularAndPluralDiffer() {
        #expect(MedicineForm.tablet.unit(for: 1) != MedicineForm.tablet.unit(for: 2))
        #expect(MedicineForm.liquid.unit(for: 1) == MedicineForm.liquid.unit(for: 2))
    }

    @Test(arguments: MedicineForm.allCases)
    func everyFormHasASystemSymbol(form: MedicineForm) {
        #expect(UIImage(systemName: form.systemImage) != nil)
    }
}
