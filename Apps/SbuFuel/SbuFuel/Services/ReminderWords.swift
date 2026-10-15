import SbuKit
import SwiftUI

/// A reminder in words: its interval, and how close it is, with the tone of the status.
struct ReminderWords {
    let reminder: ServiceReminder
    let due: ReminderDue
    let distanceUnit: DistanceUnit
    var now = Date.now
    var calendar = Calendar.current

    /// "Ogni 15.000 km o 12 mesi".
    var interval: LocalizedStringKey {
        let km = reminder.everyKm.map { distanceUnit.formatted(km: $0) }
        switch (km, reminder.everyMonths) {
        case let (km?, months?): return "Ogni \(km) o ^[\(months) mese](inflect: true)"
        case let (km?, nil): return "Ogni \(km)"
        case let (nil, months?): return "Ogni ^[\(months) mese](inflect: true)"
        case (nil, nil): return ""
        }
    }

    /// "Scaduto", "Tra 800 km", "Tra 12 giorni", "Il 14 mar 2027".
    var status: LocalizedStringKey {
        if due.status == .overdue { return "Scaduto" }
        let distanceFirst: Bool = {
            guard due.remainingKm != nil else { return false }
            guard let dueDate = due.dueDate else { return true }
            guard let estimated = due.estimatedDateForKm else { return false }
            return estimated < dueDate
        }()
        if distanceFirst, let remaining = due.remainingKm {
            return "Tra \(distanceUnit.formatted(km: remaining))"
        }
        guard let date = due.dueDate else { return "" }
        let days = calendar.dateComponents([.day], from: calendar.startOfDay(for: now), to: calendar.startOfDay(for: date)).day ?? 0
        if days <= ReminderSchedule.soonDays {
            return days == 1 ? "Domani" : "Tra ^[\(days) giorno](inflect: true)"
        }
        return "Il \(date.formatted(.dateTime.day().month(.abbreviated).year()))"
    }

    var tone: SbuStatusTone {
        switch due.status {
        case .overdue: .danger
        case .soon: .warning
        case .later: .neutral
        }
    }
}
