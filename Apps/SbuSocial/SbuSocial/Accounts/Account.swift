import Foundation

/// One login on a Platform. Its cookies live in their own website data store, named by `id`.
nonisolated struct Account: Codable, Identifiable, Hashable {
    let id: UUID
    let platform: Platform
    /// 1 for the first account on the Platform, then 2, 3…: never reused after a removal.
    let number: Int
}
