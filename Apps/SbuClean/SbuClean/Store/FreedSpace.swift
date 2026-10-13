import Foundation

/// What Sbu Clean has deleted: in total and in the last deletion.
nonisolated struct FreedSpace: Codable, Equatable, Sendable {
    var totalCount = 0
    var totalBytes: Int64 = 0
    var lastCount = 0
    var lastBytes: Int64 = 0
    var lastDate: Date?

    /// Adds one deletion to the totals and makes it the last one.
    mutating func record(count: Int, bytes: Int64, on date: Date) {
        totalCount += count
        totalBytes += bytes
        lastCount = count
        lastBytes = bytes
        lastDate = date
    }
}
