/// Which members of the duplicate and similar groups go to the bin.
///
/// Every member but the best shot starts selected; the user's taps are kept as overrides.
nonisolated struct GroupSelection: Equatable, Sendable {
    private var overrides: [String: Bool] = [:]

    func isSelected(_ id: String, in group: PhotoGroup) -> Bool {
        overrides[id] ?? (id != group.best)
    }

    mutating func toggle(_ id: String, in group: PhotoGroup) {
        overrides[id] = !isSelected(id, in: group)
    }

    /// Selects every member but the best, or none when that is already the case.
    mutating func toggleAllCopies(in group: PhotoGroup) {
        let selectAll = !areAllCopiesSelected(in: group)
        overrides[group.best] = false
        for id in group.copies {
            overrides[id] = selectAll
        }
    }

    func areAllCopiesSelected(in group: PhotoGroup) -> Bool {
        group.copies.allSatisfy { isSelected($0, in: group) }
    }

    /// The selected members of the groups, in group order.
    func selected(in groups: [PhotoGroup]) -> [String] {
        groups.flatMap { group in group.members.filter { isSelected($0, in: group) } }
    }
}
