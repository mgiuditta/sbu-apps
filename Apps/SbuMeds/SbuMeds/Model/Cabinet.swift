import Foundation
import SwiftData

/// What you do to people, medicines and doses, in one place for the screens, the notification
/// actions and the tests. Callers save.
enum Cabinet {
    static let maxNameLength = 40

    // MARK: - People

    static func people(in context: ModelContext) -> [Person] {
        (try? context.fetch(FetchDescriptor<Person>(sortBy: [SortDescriptor(\.order), SortDescriptor(\.createdAt)]))) ?? []
    }

    /// The first person, "Io", made on first launch: Medisafe starts from you too.
    @discardableResult
    static func ensurePerson(in context: ModelContext, name: String = String(localized: "Io")) -> Person {
        if let first = people(in: context).first { return first }
        return addPerson(named: name, in: context)
    }

    static func cleanName(_ name: String) -> String {
        String(name.trimmingCharacters(in: .whitespacesAndNewlines).prefix(maxNameLength))
    }

    @discardableResult
    static func addPerson(named name: String, in context: ModelContext) -> Person {
        let order = (people(in: context).map(\.order).max() ?? -1) + 1
        let person = Person(name: cleanName(name), order: order)
        context.insert(person)
        return person
    }

    static func rename(_ person: Person, to name: String) {
        let clean = cleanName(name)
        guard !clean.isEmpty else { return }
        person.name = clean
    }

    /// Deletes a person with their medicines and history. The last person stays: the app always
    /// has someone to show.
    @discardableResult
    static func delete(_ person: Person, in context: ModelContext) -> Bool {
        guard people(in: context).count > 1 else { return false }
        context.delete(person)
        return true
    }

    // MARK: - Medicines

    @discardableResult
    static func addMedicine(_ draft: MedicineDraft, for person: Person, in context: ModelContext, now: Date = .now, calendar: Calendar = .current) -> Medicine {
        let medicine = Medicine(name: draft.cleanName, form: draft.form, schedule: draft.schedule)
        apply(draft, to: medicine)
        // Days before today are never written as missed: the history starts now.
        medicine.closedThroughKey = Day(now, calendar: calendar).adding(days: -1, in: calendar).key
        context.insert(medicine)
        medicine.person = person
        return medicine
    }

    static func update(_ medicine: Medicine, with draft: MedicineDraft) {
        guard draft.isValid else { return }
        medicine.name = draft.cleanName
        apply(draft, to: medicine)
    }

    private static func apply(_ draft: MedicineDraft, to medicine: Medicine) {
        medicine.form = draft.form
        medicine.strength = draft.cleanStrength
        medicine.notes = draft.cleanNotes
        medicine.schedule = draft.schedule
        medicine.asNeededAmount = max(draft.asNeededAmount, draft.form.step)
        medicine.stock = draft.cleanStock
        medicine.refillThreshold = draft.cleanThreshold
    }

    static func delete(_ medicine: Medicine, in context: ModelContext) {
        context.delete(medicine)
    }

    static func refill(_ medicine: Medicine, adding quantity: Double) {
        guard quantity > 0 else { return }
        medicine.stock = min((medicine.stock ?? 0) + quantity, MedicineDraft.maxStock)
    }

    // MARK: - Doses

    /// Marks a scheduled dose taken or skipped; marking it again changes the mark and the stock follows.
    static func mark(_ key: DoseKey, of medicine: Medicine, as mark: DoseMark, amount: Double, at now: Date = .now, in context: ModelContext) {
        let record = medicine.record(for: key)
        let old = record?.mark
        let amount = record?.amount ?? amount
        medicine.stock = StockLevel.applying(StockLevel.change(from: old, to: mark, amount: amount), to: medicine.stock)
        if let record {
            record.mark = mark
            record.markedAt = now
            record.movedTo = nil
        } else {
            let record = DoseRecord(key: key, mark: mark, amount: amount)
            record.markedAt = now
            context.insert(record)
            record.medicine = medicine
        }
    }

    /// Undoes a mark: the dose is to take again and a taken one goes back into the stock.
    static func unmark(_ key: DoseKey, of medicine: Medicine, in context: ModelContext) {
        guard let record = medicine.record(for: key) else { return }
        medicine.stock = StockLevel.applying(StockLevel.change(from: record.mark, to: nil, amount: record.amount), to: medicine.stock)
        medicine.records = medicine.recordList.filter { $0.id != record.id }
        context.delete(record)
    }

    /// Postpones a dose to another time; it stays to take, and its reminder moves with it.
    static func move(_ key: DoseKey, of medicine: Medicine, to date: Date, amount: Double, in context: ModelContext) {
        if let record = medicine.record(for: key) {
            medicine.stock = StockLevel.applying(StockLevel.change(from: record.mark, to: .moved, amount: record.amount), to: medicine.stock)
            record.mark = .moved
            record.movedTo = date
            record.markedAt = nil
        } else {
            let record = DoseRecord(key: key, mark: .moved, amount: amount)
            record.movedTo = date
            context.insert(record)
            record.medicine = medicine
        }
    }

    /// A dose outside the schedule, now: as needed, or one more from the medicine's screen.
    @discardableResult
    static func takeExtra(_ medicine: Medicine, amount: Double, at now: Date = .now, calendar: Calendar = .current, in context: ModelContext) -> DoseRecord {
        let minutes = calendar.component(.hour, from: now) * 60 + calendar.component(.minute, from: now)
        let record = DoseRecord(key: DoseKey(medicineID: medicine.id, day: Day(now, calendar: calendar), minutes: minutes), mark: .taken, amount: amount, isExtra: true)
        record.markedAt = now
        context.insert(record)
        record.medicine = medicine
        medicine.stock = StockLevel.applying(-amount, to: medicine.stock)
        return record
    }

    /// Removes an extra dose and puts it back into the stock.
    static func delete(_ record: DoseRecord, in context: ModelContext) {
        if let medicine = record.medicine {
            medicine.stock = StockLevel.applying(StockLevel.change(from: record.mark, to: nil, amount: record.amount), to: medicine.stock)
            medicine.records = medicine.recordList.filter { $0.id != record.id }
        }
        context.delete(record)
    }

    /// Writes the unmarked doses of the days that ended as missed. Run at launch, when the app
    /// comes back and at midnight.
    static func closePastDays(in context: ModelContext, now: Date = .now, calendar: Calendar = .current) {
        let yesterday = Day(now, calendar: calendar).adding(days: -1, in: calendar)
        let medicines = (try? context.fetch(FetchDescriptor<Medicine>())) ?? []
        for medicine in medicines where medicine.closedThroughKey < yesterday.key {
            let keys = MissedDoses.keys(for: medicine.snapshot, closedThrough: Day(key: medicine.closedThroughKey), yesterday: yesterday, calendar: calendar)
            let amounts = Dictionary(medicine.schedule.effectiveTimes.map { ($0.minutes, $0.amount) }, uniquingKeysWith: { first, _ in first })
            for key in keys {
                if let moved = medicine.record(for: key) {
                    moved.mark = .missed
                    moved.movedTo = nil
                } else {
                    let record = DoseRecord(key: key, mark: .missed, amount: amounts[key.minutes] ?? 1)
                    context.insert(record)
                    record.medicine = medicine
                }
            }
            medicine.closedThroughKey = yesterday.key
        }
    }
}
