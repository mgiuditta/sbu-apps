import Foundation

/// The one "Da ricomprare" notification waiting to be delivered.
nonisolated struct PlannedReminder: Equatable, Sendable {
    static let identifier = "low-stock"

    let title: String
    let body: String
    let date: Date
}
