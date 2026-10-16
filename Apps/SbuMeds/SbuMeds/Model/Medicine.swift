import Foundation
import SwiftData

/// A medicine one person takes: what it is, its schedule, its stock and its history.
///
/// The schedule lives in `Schedule`, a pure type; this class stores it flat, so every attribute
/// has a default and iCloud could mirror it later.
@Model
final class Medicine {
    var id = UUID()
    var name = ""
    var formRaw = MedicineForm.tablet.rawValue
    /// As on the box, such as "500 mg": shown, never computed with.
    var strength = ""
    var notes = ""

    var frequencyRaw = Frequency.daily.rawValue
    var timeMinutes: [Int] = [8 * 60]
    var timeAmounts: [Double] = [1]
    var weekdays: [Int] = []
    var interval = 2
    var cycleOn = 21
    var cycleOff = 7
    var startKey = 0
    var endKey: Int?
    /// How much at a time when taken as needed.
    var asNeededAmount: Double = 1

    /// Units left, `nil` when you don't count them.
    var stock: Double?
    /// Below or at this, a refill reminder.
    var refillThreshold: Double?
    /// The last day whose unmarked doses were written to the history as missed.
    var closedThroughKey = 0
    var createdAt = Date.now

    var person: Person?
    @Relationship(deleteRule: .cascade, inverse: \DoseRecord.medicine) var records: [DoseRecord]? = []

    init(name: String, form: MedicineForm, schedule: Schedule) {
        self.name = name
        formRaw = form.rawValue
        startKey = schedule.start.key
        self.schedule = schedule
    }

    var form: MedicineForm {
        get { MedicineForm(rawValue: formRaw) ?? .other }
        set { formRaw = newValue.rawValue }
    }

    var schedule: Schedule {
        get {
            let times = zip(timeMinutes, timeAmounts + Array(repeating: 1, count: max(timeMinutes.count - timeAmounts.count, 0)))
                .map { DoseTime(minutes: $0, amount: $1) }
            return Schedule(
                frequency: Frequency(rawValue: frequencyRaw) ?? .daily, times: times, weekdays: Set(weekdays),
                interval: interval, cycleOn: cycleOn, cycleOff: cycleOff,
                start: Day(key: startKey), end: endKey.map(Day.init(key:))
            )
        }
        set {
            frequencyRaw = newValue.frequency.rawValue
            timeMinutes = newValue.times.map(\.minutes)
            timeAmounts = newValue.times.map(\.amount)
            weekdays = newValue.weekdays.sorted()
            interval = newValue.interval
            cycleOn = newValue.cycleOn
            cycleOff = newValue.cycleOff
            startKey = newValue.start.key
            endKey = newValue.end?.key
        }
    }

    var recordList: [DoseRecord] { records ?? [] }

    var snapshot: MedicineSnapshot {
        MedicineSnapshot(
            id: id, personID: person?.id ?? id, personName: person?.name ?? "", name: name, form: form, strength: strength,
            schedule: schedule, asNeededAmount: asNeededAmount, stock: stock, refillThreshold: refillThreshold,
            records: recordList.map(\.snapshot), closedThrough: closedThroughKey > 0 ? Day(key: closedThroughKey) : nil
        )
    }

    /// The record of one scheduled dose, if marked.
    func record(for key: DoseKey) -> DoseRecord? {
        recordList.first { !$0.isExtra && $0.dayKey == key.day.key && $0.minutes == key.minutes }
    }
}
