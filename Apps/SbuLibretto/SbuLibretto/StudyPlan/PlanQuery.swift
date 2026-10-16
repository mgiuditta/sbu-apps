import Foundation

/// Filters, orders and groups the study plan by year of the course.
///
/// Exams without what the order needs go last whatever the direction: no date when ordering by
/// date; idoneità and then exams still to take when ordering by grade. Ties go by name.
nonisolated struct PlanQuery: Hashable, Sendable {
    /// One year of the course and its exams, in order.
    struct Group: Hashable, Identifiable, Sendable {
        let courseYear: Int
        let items: [PlanItem]
        var id: Int { courseYear }
    }

    var status = PlanStatus.all
    /// One year of the course, or `nil` for all.
    var courseYear: Int?
    var sort = PlanSort.date
    /// Newest, highest or largest first.
    var descending = true

    /// The years that have exams, in order.
    static func courseYears(in items: [PlanItem]) -> [Int] {
        Set(items.map(\.courseYear)).sorted()
    }

    func groups(_ items: [PlanItem]) -> [Group] {
        let shown = items.filter { status.includes($0.result) && (courseYear == nil || $0.courseYear == courseYear) }
        return Dictionary(grouping: shown, by: \.courseYear)
            .sorted { $0.key < $1.key }
            .map { Group(courseYear: $0.key, items: $0.value.sorted(by: inOrder)) }
    }

    private func inOrder(_ left: PlanItem, _ right: PlanItem) -> Bool {
        let leftKey = key(left)
        let rightKey = key(right)
        if leftKey.tier != rightKey.tier { return leftKey.tier < rightKey.tier }
        if leftKey.value != rightKey.value { return descending ? leftKey.value > rightKey.value : leftKey.value < rightKey.value }
        let byName = left.name.localizedStandardCompare(right.name)
        return byName == .orderedSame ? left.id.uuidString < right.id.uuidString : byName == .orderedAscending
    }

    /// The tier puts the exams without the value last; the value orders within the tier.
    private func key(_ item: PlanItem) -> (tier: Int, value: Double) {
        switch sort {
        case .date:
            guard let date = item.date else { return (1, 0) }
            return (0, date.timeIntervalSinceReferenceDate)
        case .credits:
            return (0, item.credits)
        case .grade:
            switch item.result {
            // Cum laude above 30, whatever it is worth in the average.
            case let .graded(grade): return (0, grade.isCumLaude ? 31 : Double(grade.mark))
            case .passed: return (1, 0)
            case .pending: return (2, 0)
            }
        }
    }
}
