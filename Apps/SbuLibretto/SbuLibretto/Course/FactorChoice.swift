import SwiftUI

/// How the average turns into hundred-and-tenths: the usual 110/30, Sapienza's × 4, or a factor of your own.
nonisolated enum FactorChoice: String, CaseIterable, Identifiable, Sendable {
    case standard
    case four
    case custom

    var id: Self { self }

    init(factor: Double) {
        if abs(factor - GradeRules.standardFactor) < 1e-9 {
            self = .standard
        } else if factor == 4 {
            self = .four
        } else {
            self = .custom
        }
    }

    /// The factor a preset stands for; `nil` for your own.
    var factor: Double? {
        switch self {
        case .standard: GradeRules.standardFactor
        case .four: 4
        case .custom: nil
        }
    }

    var title: LocalizedStringKey {
        switch self {
        case .standard: "× 110/30"
        case .four: "× 4"
        case .custom: "Altro"
        }
    }
}
