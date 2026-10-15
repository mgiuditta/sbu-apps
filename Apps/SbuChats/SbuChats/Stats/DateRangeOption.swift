import Foundation

/// The period the chat's numbers cover.
///
/// The recent periods end at the chat's last message, not today: an export from last spring
/// still has its "last 30 days".
nonisolated enum DateRangeOption: String, CaseIterable, Identifiable, Sendable {
    case all
    case last30Days
    case last6Months
    case lastYear
    case custom

    var id: Self { self }

    /// The first and last moment included; `nil` means no limit on that side.
    /// - Parameters:
    ///   - lastMessage: The chat's last message, where recent periods end.
    ///   - customStart: The first day of a custom period.
    ///   - customEnd: The last day of a custom period, included whole.
    func bounds(lastMessage: Date, customStart: Date, customEnd: Date, calendar: Calendar) -> (start: Date?, end: Date?) {
        let endOfLastDay = calendar.date(byAdding: DateComponents(day: 1, second: -1), to: calendar.startOfDay(for: lastMessage)) ?? lastMessage
        func since(_ components: DateComponents) -> Date? {
            calendar.date(byAdding: components, to: calendar.startOfDay(for: lastMessage)).map { calendar.date(byAdding: .day, value: 1, to: $0) ?? $0 }
        }
        switch self {
        case .all:
            return (nil, nil)
        case .last30Days:
            return (since(DateComponents(day: -30)), endOfLastDay)
        case .last6Months:
            return (since(DateComponents(month: -6)), endOfLastDay)
        case .lastYear:
            return (since(DateComponents(year: -1)), endOfLastDay)
        case .custom:
            let start = calendar.startOfDay(for: min(customStart, customEnd))
            let lastDay = calendar.startOfDay(for: max(customStart, customEnd))
            let end = calendar.date(byAdding: DateComponents(day: 1, second: -1), to: lastDay) ?? lastDay
            return (start, end)
        }
    }

    /// The name in the period menu.
    var title: LocalizedStringResource {
        switch self {
        case .all: "Tutta la chat"
        case .last30Days: "Ultimi 30 giorni"
        case .last6Months: "Ultimi 6 mesi"
        case .lastYear: "Ultimo anno"
        case .custom: "Personalizzato"
        }
    }
}
