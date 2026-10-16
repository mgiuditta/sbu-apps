import Foundation
import SwiftData

/// A made-up family for previews and screenshots, never the user's own: three people, their
/// medicines, two weeks of history with a skipped and a missed dose, this morning taken.
enum SampleFamily {
    static func insert(into context: ModelContext, now: Date, calendar: Calendar) {
        let today = Day(now, calendar: calendar)
        let me = Cabinet.addPerson(named: String(localized: "Io"), in: context)
        let child = Cabinet.addPerson(named: String(localized: "Luca"), in: context)
        let grandma = Cabinet.addPerson(named: String(localized: "Nonna Rita"), in: context)

        func draft(_ name: LocalizedStringResource, _ form: MedicineForm, strength: String = "", times: [DoseTime], frequency: Frequency = .daily, startDaysAgo: Int = 30) -> MedicineDraft {
            var draft = MedicineDraft(today: today.adding(days: -startDaysAgo, in: calendar), calendar: calendar)
            draft.name = String(localized: name)
            draft.form = form
            draft.strength = strength
            draft.times = times
            draft.frequency = frequency
            return draft
        }

        var vitaminD = draft("Vitamina D", .drops, times: [DoseTime(hour: 8, amount: 10)])
        vitaminD.tracksStock = true
        vitaminD.stock = 180
        vitaminD.refillThreshold = 50
        var thyroid = draft("Levotiroxina", .tablet, strength: "50 µg", times: [DoseTime(hour: 7, minute: 30)])
        thyroid.tracksStock = true
        thyroid.stock = 6
        thyroid.refillThreshold = 7
        let omega = draft("Omega 3", .capsule, strength: "1000 mg", times: [DoseTime(hour: 8), DoseTime(hour: 20)])
        var iron = draft("Ferro", .tablet, times: [DoseTime(hour: 13)], frequency: .everyDays)
        iron.everyDays = 2
        let mine = [vitaminD, thyroid, omega, iron].map { Cabinet.addMedicine($0, for: me, in: context, now: now, calendar: calendar) }

        var syrup = draft("Sciroppo per la tosse", .liquid, times: [DoseTime(hour: 8, amount: 5), DoseTime(hour: 14, amount: 5), DoseTime(hour: 20, amount: 5)], startDaysAgo: 2)
        syrup.hasEnd = true
        syrup.end = today.adding(days: 4, in: calendar)
        var antihistamine = draft("Antistaminico", .tablet, strength: "10 mg", times: [], frequency: .asNeeded)
        antihistamine.asNeededAmount = 1
        let childs = [syrup, antihistamine].map { Cabinet.addMedicine($0, for: child, in: context, now: now, calendar: calendar) }

        var pressure = draft("Ramipril", .tablet, strength: "5 mg", times: [DoseTime(hour: 8)])
        pressure.tracksStock = true
        pressure.stock = 24
        pressure.refillThreshold = 7
        let statin = draft("Atorvastatina", .tablet, strength: "20 mg", times: [DoseTime(hour: 21)])
        let drops = draft("Collirio", .drops, times: [DoseTime(hour: 9, amount: 2), DoseTime(hour: 21, amount: 2)])
        var b12 = draft("Vitamina B12", .injection, times: [DoseTime(hour: 10)], frequency: .weekdays)
        b12.weekdays = [2]
        let grandmas = [pressure, statin, drops, b12].map { Cabinet.addMedicine($0, for: grandma, in: context, now: now, calendar: calendar) }

        // Two weeks of history: everything taken a few minutes late, one skipped, one missed.
        for medicine in mine + childs + grandmas {
            medicine.closedThroughKey = today.adding(days: -15, in: calendar).key
            let snapshot = medicine.snapshot
            for back in 1...14 {
                let day = today.adding(days: -back, in: calendar)
                for time in snapshot.schedule.times(on: day, calendar: calendar) {
                    let key = DoseKey(medicineID: medicine.id, day: day, minutes: time.minutes)
                    let mark: DoseMark = (back == 3 && time.minutes >= 20 * 60) ? .skipped : (back == 6 && time.minutes < 9 * 60) ? .missed : .taken
                    let record = DoseRecord(key: key, mark: mark, amount: time.amount)
                    record.markedAt = mark == .missed ? nil : key.date(in: calendar).addingTimeInterval(Double(back % 4) * 240)
                    context.insert(record)
                    record.medicine = medicine
                }
            }
            medicine.closedThroughKey = today.adding(days: -1, in: calendar).key
            // This morning, before now: taken, without touching the stock already counted above.
            for time in snapshot.schedule.times(on: today, calendar: calendar) {
                let key = DoseKey(medicineID: medicine.id, day: today, minutes: time.minutes)
                let due = key.date(in: calendar)
                guard due < now, time.minutes < 12 * 60 else { continue }
                let record = DoseRecord(key: key, mark: .taken, amount: time.amount)
                record.markedAt = due.addingTimeInterval(180)
                context.insert(record)
                record.medicine = medicine
            }
        }
        if let asNeeded = childs.last {
            Cabinet.takeExtra(asNeeded, amount: 1, at: min(now, today.date(atMinutes: 7 * 60, in: calendar)), calendar: calendar, in: context)
        }
    }
}
