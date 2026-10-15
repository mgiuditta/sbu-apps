import Foundation

/// How close a service is, always shown with a word.
nonisolated enum ReminderStatus: Int, Comparable, Sendable {
    case overdue
    case soon
    case later

    static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}
