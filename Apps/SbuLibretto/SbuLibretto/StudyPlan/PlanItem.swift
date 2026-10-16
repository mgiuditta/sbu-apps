import Foundation

/// An exam as the study plan lists it.
nonisolated struct PlanItem: Hashable, Identifiable, Sendable {
    let id: UUID
    let name: String
    let credits: Double
    let courseYear: Int
    let result: ExamResult
    let date: Date?
}
