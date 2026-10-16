import Foundation

/// The exams still to take, by their sitting: coming ones first, soonest first; then the ones whose
/// date has passed without a grade; then the ones with no date yet, by name.
nonisolated struct ExamCountdown: Sendable {
    struct Sitting: Hashable, Identifiable, Sendable {
        let id: UUID
        let name: String
        let credits: Double
        let date: Date
        let day: CountdownDay
    }

    let upcoming: [Sitting]
    /// Dated before today and still without a grade: register it, or move the date.
    let overdue: [Sitting]
    let undated: [PlanItem]

    init(_ items: [PlanItem], now: Date, calendar: Calendar) {
        let pending = items.filter { !$0.result.isDone }
        let dated = pending.compactMap { item in
            item.date.map { Sitting(id: item.id, name: item.name, credits: item.credits, date: $0, day: CountdownDay($0, from: now, calendar: calendar)) }
        }
        upcoming = dated.filter { !$0.day.isPast }.sorted { ($0.date, $0.name) < ($1.date, $1.name) }
        overdue = dated.filter(\.day.isPast).sorted { ($0.date, $0.name) > ($1.date, $1.name) }
        undated = pending.filter { $0.date == nil }.sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
    }

    var next: Sitting? {
        upcoming.first
    }

    var isEmpty: Bool {
        upcoming.isEmpty && overdue.isEmpty && undated.isEmpty
    }
}
