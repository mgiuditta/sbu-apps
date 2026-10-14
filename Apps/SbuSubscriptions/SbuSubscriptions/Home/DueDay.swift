import Foundation

/// When a payment falls, as the home row says it: today, tomorrow, within the week, or on a date.
nonisolated enum DueDay: Hashable, Sendable {
    case today
    case tomorrow
    case inDays(Int)
    case on(Date)

    init(_ payment: Date, from date: Date, in calendar: Calendar) {
        let days = calendar.dateComponents([.day], from: calendar.startOfDay(for: date), to: calendar.startOfDay(for: payment)).day ?? 0
        switch days {
        case ...0: self = .today
        case 1: self = .tomorrow
        case 2...6: self = .inDays(days)
        default: self = .on(payment)
        }
    }
}
