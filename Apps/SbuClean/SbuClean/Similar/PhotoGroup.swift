/// A group of duplicate or similar photos, the best one first.
nonisolated struct PhotoGroup: Identifiable, Hashable, Sendable {
    var kind: GroupKind
    /// Identifiers with the suggested best shot first; at least two.
    var members: [String]

    /// The best shot's identifier, which also names the group.
    var id: String {
        members[0]
    }

    /// The suggested photo to keep.
    var best: String {
        members[0]
    }

    /// The other members, preselected for the bin.
    var copies: ArraySlice<String> {
        members.dropFirst()
    }
}
