import Foundation

/// One scheduled dose: a medicine, a day and the local time it was due.
///
/// Records and notifications point to a dose by this key, so changing a medicine's times later
/// never moves what you already marked: yesterday's 8:00 stays yesterday's 8:00.
nonisolated struct DoseKey: Hashable, Codable, Sendable {
    let medicineID: UUID
    let day: Day
    let minutes: Int

    /// The stored form, for notifications: `medicineID|yyyymmdd|minutes`.
    var string: String { "\(medicineID.uuidString)|\(day.key)|\(minutes)" }

    init(medicineID: UUID, day: Day, minutes: Int) {
        self.medicineID = medicineID
        self.day = day
        self.minutes = minutes
    }

    init?(string: String) {
        let parts = string.split(separator: "|")
        guard parts.count == 3, let id = UUID(uuidString: String(parts[0])), let day = Int(parts[1]), let minutes = Int(parts[2]) else {
            return nil
        }
        self.init(medicineID: id, day: Day(key: day), minutes: minutes)
    }

    func date(in calendar: Calendar) -> Date {
        day.date(atMinutes: minutes, in: calendar)
    }
}
