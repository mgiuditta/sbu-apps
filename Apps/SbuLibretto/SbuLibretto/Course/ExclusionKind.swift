import SwiftUI

/// Whether the worst grades leave the average, counted in credits or in exams.
nonisolated enum ExclusionKind: String, CaseIterable, Identifiable, Sendable {
    case none
    case credits
    case exams

    var id: Self { self }

    init(_ exclusion: WorstExclusion) {
        switch exclusion {
        case .none: self = .none
        case .credits: self = .credits
        case .exams: self = .exams
        }
    }

    /// The exclusion of this kind, keeping the amount when there is one; a new kind starts from
    /// MyLibretto's usual 12 CFU, or one exam.
    func exclusion(from current: WorstExclusion) -> WorstExclusion {
        switch (self, current) {
        case (.none, _): .none
        case (.credits, .credits): current
        case (.exams, .exams): current
        case (.credits, _): .credits(12)
        case (.exams, _): .exams(1)
        }
    }

    var title: LocalizedStringKey {
        switch self {
        case .none: "Nessuno"
        case .credits: "Per CFU"
        case .exams: "Per esami"
        }
    }
}
