import SwiftUI

/// What the study plan is ordered by, as in the original: date, grade or credits.
nonisolated enum PlanSort: String, CaseIterable, Identifiable, Sendable {
    case date
    case grade
    case credits

    var id: Self { self }

    var title: LocalizedStringKey {
        switch self {
        case .date: "Data"
        case .grade: "Voto"
        case .credits: "CFU"
        }
    }
}
