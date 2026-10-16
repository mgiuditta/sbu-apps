import Foundation

/// What the medicine form edits, checked before it reaches the store.
nonisolated struct MedicineDraft: Equatable, Sendable {
    static let maxNameLength = 60
    static let maxStrengthLength = 30
    static let maxNotesLength = 1_000
    static let maxTimes = 12
    static let maxStock = 9_999.0

    var name = ""
    var form = MedicineForm.tablet
    var strength = ""
    var notes = ""
    var frequency = Frequency.daily
    var times = [DoseTime(hour: 8)]
    var weekdays: Set<Int> = [2, 3, 4, 5, 6]
    var everyDays = 2
    var everyHours = 8
    var cycleOn = 21
    var cycleOff = 7
    var start: Day
    var hasEnd = false
    var end: Day
    var asNeededAmount: Double = 1
    var tracksStock = false
    var stock: Double = 30
    var refillThreshold: Double = 10

    init(today: Day, calendar: Calendar) {
        start = today
        end = today.adding(days: 6, in: calendar)
    }

    init(medicine: MedicineSnapshot, calendar: Calendar) {
        let schedule = medicine.schedule
        self.init(today: schedule.start, calendar: calendar)
        name = medicine.name
        form = medicine.form
        strength = medicine.strength
        frequency = schedule.frequency
        if !schedule.times.isEmpty { times = schedule.times }
        if !schedule.weekdays.isEmpty { weekdays = schedule.weekdays }
        if schedule.frequency == .everyDays { everyDays = schedule.interval }
        if schedule.frequency == .everyHours { everyHours = schedule.interval }
        cycleOn = schedule.cycleOn
        cycleOff = schedule.cycleOff
        if let last = schedule.end {
            hasEnd = true
            end = last
        }
        asNeededAmount = medicine.asNeededAmount
        if let stock = medicine.stock {
            tracksStock = true
            self.stock = stock
            refillThreshold = medicine.refillThreshold ?? 0
        }
    }

    var cleanName: String { Self.clean(name, max: Self.maxNameLength) }
    var cleanStrength: String { Self.clean(strength, max: Self.maxStrengthLength) }
    var cleanNotes: String { Self.clean(notes, max: Self.maxNotesLength) }

    private static func clean(_ text: String, max: Int) -> String {
        String(text.trimmingCharacters(in: .whitespacesAndNewlines).prefix(max))
    }

    var problem: Problem? {
        if cleanName.isEmpty { return .noName }
        switch frequency {
        case .asNeeded: break
        case .weekdays where weekdays.isEmpty: return .noWeekdays
        default: if times.isEmpty { return .noTimes }
        }
        if hasEnd, end < start { return .endBeforeStart }
        return nil
    }

    var isValid: Bool { problem == nil }

    nonisolated enum Problem: Equatable, Sendable {
        case noName
        case noTimes
        case noWeekdays
        case endBeforeStart
    }

    /// The schedule as saved: hourly schedules keep their first time only, as needed none.
    var schedule: Schedule {
        let interval = switch frequency {
        case .everyDays: everyDays
        case .everyHours: everyHours
        default: 2
        }
        let saved: [DoseTime] = switch frequency {
        case .asNeeded: []
        case .everyHours: Array(Schedule.normalized(times).prefix(1))
        default: times
        }
        return Schedule(
            frequency: frequency, times: saved, weekdays: frequency == .weekdays ? weekdays : [],
            interval: interval, cycleOn: cycleOn, cycleOff: cycleOff, start: start, end: hasEnd ? end : nil
        )
    }

    /// The times the form lists: for every N hours, all of them, from the first.
    var shownTimes: [DoseTime] {
        frequency == .everyHours ? schedule.effectiveTimes : Schedule.normalized(times)
    }

    /// A new time an hour after the last one, or 8:00; never past 23:59 and never a duplicate.
    mutating func addTime() {
        guard times.count < Self.maxTimes else { return }
        let taken = Set(times.map(\.minutes))
        var minutes = (times.map(\.minutes).max() ?? 7 * 60) + 60
        while minutes < DoseTime.minutesInDay, taken.contains(minutes) { minutes += 1 }
        if minutes >= DoseTime.minutesInDay {
            minutes = (0..<DoseTime.minutesInDay).first { !taken.contains($0) } ?? 0
        }
        times.append(DoseTime(minutes: minutes, amount: times.last?.amount ?? 1))
        times = Schedule.normalized(times)
    }

    mutating func removeTime(at index: Int) {
        guard times.indices.contains(index), times.count > 1 else { return }
        times.remove(at: index)
    }

    var cleanStock: Double? { tracksStock ? min(max(stock, 0), Self.maxStock) : nil }
    var cleanThreshold: Double? { tracksStock ? min(max(refillThreshold, 0), Self.maxStock) : nil }
}
