import Foundation

/// A local notification to hand to iOS: at a day and time, or right away when `fireDate` is nil.
nonisolated struct PlannedNotification: Equatable, Sendable {
    let identifier: String
    let title: String
    let body: String
    let fireDate: Date?
}
