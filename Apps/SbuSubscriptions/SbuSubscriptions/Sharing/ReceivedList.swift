import Foundation

/// A list someone shared with you, as last read from iCloud.
nonisolated struct ReceivedList: Codable, Equatable, Identifiable, Sendable {
    /// The owner and the zone, from `CloudKitSharedLists.key(of:)`.
    let key: String
    var ownerName: String?
    var snapshot: SharedListSnapshot

    var id: String { key }
}

/// The shared lists received, in a file of their own.
nonisolated struct ReceivedListsFile: Codable, Equatable, Sendable {
    static let currentVersion = 1

    var version = currentVersion
    var lists: [ReceivedList] = []
    /// Keys the user removed, hidden until iCloud confirms they left.
    var removed: Set<String> = []
}
