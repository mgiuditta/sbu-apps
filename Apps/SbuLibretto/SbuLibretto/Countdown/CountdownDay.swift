import Foundation

/// How far a sitting is from today, in calendar days: "Oggi", "Domani", "Tra 12 giorni", "Ieri", "3 giorni fa".
nonisolated enum CountdownDay: Hashable, Sendable {
    case today
    case tomorrow
    /// Two days or more ahead.
    case inDays(Int)
    case yesterday
    /// Two days or more ago.
    case daysAgo(Int)

    /// Counts calendar days, midnight to midnight, so 23:59 tonight is still today.
    init(_ date: Date, from now: Date, calendar: Calendar) {
        let days = calendar.dateComponents([.day], from: calendar.startOfDay(for: now), to: calendar.startOfDay(for: date)).day ?? 0
        switch days {
        case 0: self = .today
        case 1: self = .tomorrow
        case -1: self = .yesterday
        case let days where days > 1: self = .inDays(days)
        default: self = .daysAgo(-days)
        }
    }

    var isPast: Bool {
        switch self {
        case .yesterday, .daysAgo: true
        case .today, .tomorrow, .inDays: false
        }
    }

    /// The words, in the phone's language.
    var text: String {
        switch self {
        case .today: String(localized: "Oggi")
        case .tomorrow: String(localized: "Domani")
        case let .inDays(days): String(localized: "Tra \(days) giorni")
        case .yesterday: String(localized: "Ieri")
        case let .daysAgo(days): String(localized: "\(days) giorni fa")
        }
    }
}
