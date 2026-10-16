import SwiftUI

/// Which exams the study plan shows: all, the ones taken, or the ones still to take.
nonisolated enum PlanStatus: String, CaseIterable, Identifiable, Sendable {
    case all
    case taken
    case pending

    var id: Self { self }

    func includes(_ result: ExamResult) -> Bool {
        switch self {
        case .all: true
        case .taken: result.isDone
        case .pending: !result.isDone
        }
    }

    var title: LocalizedStringKey {
        switch self {
        case .all: "Tutti"
        case .taken: "Sostenuti"
        case .pending: "Da sostenere"
        }
    }
}
