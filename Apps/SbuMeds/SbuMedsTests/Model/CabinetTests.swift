import Foundation
import SwiftData
import Testing
@testable import SbuMeds

/// The store operations, each on a fresh in-memory container.
struct CabinetTests {
    private let container: ModelContainer
    private var context: ModelContext { container.mainContext }
    private let calendar = Fixtures.calendar
    private let now = Fixtures.now

    init() throws {
        container = try ModelContainer.meds(inMemory: true)
    }

    private func draft(_ name: String = "Ramipril", times: [DoseTime] = [DoseTime(hour: 8)], stock: Double? = nil, start: Day = Fixtures.today) -> MedicineDraft {
        var draft = MedicineDraft(today: start, calendar: calendar)
        draft.name = name
        draft.times = times
        if let stock {
            draft.tracksStock = true
            draft.stock = stock
            draft.refillThreshold = 5
        }
        return draft
    }

    private func key(_ medicine: Medicine, _ hour: Int, day: Day = Fixtures.today) -> DoseKey {
        DoseKey(medicineID: medicine.id, day: day, minutes: hour * 60)
    }

    @Test func theFirstPersonIsMadeOnceAndTheLastNeverGoes() throws {
        let me = Cabinet.ensurePerson(in: context, name: "Io")
        #expect(Cabinet.ensurePerson(in: context, name: "Altro").id == me.id)
        #expect(!Cabinet.delete(me, in: context))
        let child = Cabinet.addPerson(named: "  Luca  ", in: context)
        #expect(child.name == "Luca")
        #expect(child.order == 1)
        #expect(Cabinet.delete(child, in: context))
        try context.save()
        #expect(Cabinet.people(in: context).map(\.name) == ["Io"])
    }

    @Test func deletingAPersonDeletesTheirMedicinesAndHistory() throws {
        Cabinet.ensurePerson(in: context)
        let child = Cabinet.addPerson(named: "Luca", in: context)
        let medicine = Cabinet.addMedicine(draft(), for: child, in: context, now: now, calendar: calendar)
        Cabinet.mark(key(medicine, 8), of: medicine, as: .taken, amount: 1, at: now, in: context)
        try context.save()
        Cabinet.delete(child, in: context)
        try context.save()
        #expect(try context.fetchCount(FetchDescriptor<Medicine>()) == 0)
        #expect(try context.fetchCount(FetchDescriptor<DoseRecord>()) == 0)
    }

    @Test func takingADoseComesOffTheStockAndUndoingPutsItBack() throws {
        let person = Cabinet.ensurePerson(in: context)
        let medicine = Cabinet.addMedicine(draft(times: [DoseTime(hour: 8, amount: 2)], stock: 10), for: person, in: context, now: now, calendar: calendar)
        Cabinet.mark(key(medicine, 8), of: medicine, as: .taken, amount: 2, at: now, in: context)
        #expect(medicine.stock == 8)
        // Marking it again changes the mark, never counts twice.
        Cabinet.mark(key(medicine, 8), of: medicine, as: .taken, amount: 2, at: now, in: context)
        #expect(medicine.stock == 8)
        Cabinet.mark(key(medicine, 8), of: medicine, as: .skipped, amount: 2, at: now, in: context)
        #expect(medicine.stock == 10)
        Cabinet.mark(key(medicine, 8), of: medicine, as: .taken, amount: 2, at: now, in: context)
        Cabinet.unmark(key(medicine, 8), of: medicine, in: context)
        try context.save()
        #expect(medicine.stock == 10)
        #expect(medicine.recordList.isEmpty)
    }

    @Test func extraDosesCountAndCanBeRemoved() throws {
        let person = Cabinet.ensurePerson(in: context)
        let medicine = Cabinet.addMedicine(draft(stock: 10), for: person, in: context, now: now, calendar: calendar)
        let extra = Cabinet.takeExtra(medicine, amount: 1, at: now, calendar: calendar, in: context)
        #expect(medicine.stock == 9)
        #expect(extra.minutes == 12 * 60)
        #expect(medicine.record(for: DoseKey(medicineID: medicine.id, day: Fixtures.today, minutes: 12 * 60)) == nil)
        Cabinet.delete(extra, in: context)
        try context.save()
        #expect(medicine.stock == 10)
    }

    @Test func refillAddsToTheStock() {
        let person = Cabinet.ensurePerson(in: context)
        let medicine = Cabinet.addMedicine(draft(stock: 3), for: person, in: context, now: now, calendar: calendar)
        Cabinet.refill(medicine, adding: 28)
        #expect(medicine.stock == 31)
        Cabinet.refill(medicine, adding: -5)
        #expect(medicine.stock == 31)
    }

    @Test func aMovedDoseStaysToTakeAtItsNewTime() throws {
        let person = Cabinet.ensurePerson(in: context)
        let medicine = Cabinet.addMedicine(draft(stock: 10), for: person, in: context, now: now, calendar: calendar)
        let later = Fixtures.date(2026, 10, 16, 13)
        Cabinet.move(key(medicine, 8), of: medicine, to: later, amount: 1, in: context)
        let item = try #require(DayPlan([medicine.snapshot], day: Fixtures.today, now: now, calendar: calendar).items.first)
        #expect(item.dueDate == later)
        #expect(item.state == .upcoming)
        #expect(medicine.stock == 10)
    }

    @Test func endedDaysAreClosedOnceAsMissed() throws {
        let person = Cabinet.ensurePerson(in: context)
        let medicine = Cabinet.addMedicine(draft(times: [DoseTime(hour: 8), DoseTime(hour: 20)], start: Fixtures.day(-3)), for: person, in: context, now: Fixtures.date(2026, 10, 13), calendar: calendar)
        Cabinet.mark(key(medicine, 8, day: Fixtures.day(-2)), of: medicine, as: .taken, amount: 1, at: now, in: context)
        Cabinet.move(key(medicine, 20, day: Fixtures.day(-1)), of: medicine, to: Fixtures.date(2026, 10, 15, 22), amount: 1, in: context)
        try context.save()

        Cabinet.closePastDays(in: context, now: now, calendar: calendar)
        try context.save()
        let marks = medicine.recordList.sorted { ($0.dayKey, $0.minutes) < ($1.dayKey, $1.minutes) }.map(\.mark)
        // The start day counts whole, as on Today: its 8:00 shows late from noon, then missed.
        #expect(marks == [.missed, .missed, .taken, .missed, .missed, .missed])
        #expect(medicine.closedThroughKey == Fixtures.day(-1).key)

        // Again the same day: nothing more.
        Cabinet.closePastDays(in: context, now: now, calendar: calendar)
        #expect(medicine.recordList.count == 6)
    }

    @Test func aMedicineAddedTodayHasNoPastToClose() throws {
        let person = Cabinet.ensurePerson(in: context)
        let medicine = Cabinet.addMedicine(draft(start: Fixtures.day(-10)), for: person, in: context, now: now, calendar: calendar)
        Cabinet.closePastDays(in: context, now: now, calendar: calendar)
        #expect(medicine.recordList.isEmpty)
    }

    @Test func changingTheScheduleNeverRewritesTheHistory() throws {
        let person = Cabinet.ensurePerson(in: context)
        let medicine = Cabinet.addMedicine(draft(start: Fixtures.day(-3)), for: person, in: context, now: Fixtures.date(2026, 10, 13, 6), calendar: calendar)
        Cabinet.closePastDays(in: context, now: now, calendar: calendar)
        let before = medicine.recordList.count
        var edited = draft(times: [DoseTime(hour: 9), DoseTime(hour: 21)], start: Fixtures.day(-3))
        edited.name = "Ramipril"
        Cabinet.update(medicine, with: edited)
        Cabinet.closePastDays(in: context, now: now, calendar: calendar)
        #expect(medicine.recordList.count == before)
        #expect(Set(medicine.recordList.map(\.minutes)) == [8 * 60])
    }

    @Test func theSampleFamilyLoads() throws {
        SampleFamily.insert(into: context, now: now, calendar: calendar)
        try context.save()
        #expect(Cabinet.people(in: context).count == 3)
        #expect(try context.fetchCount(FetchDescriptor<DoseRecord>()) > 50)
    }
}
