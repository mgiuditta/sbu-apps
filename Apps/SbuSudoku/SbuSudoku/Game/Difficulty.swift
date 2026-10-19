import Foundation

/// The six difficulties of the original, easiest first.
///
/// What sets them apart is the number of givens: the ranges follow the original's catalog
/// (Easy 38, Medium about 36, Hard about 31, Expert about 30, Evil about 26, Extreme about 23).
nonisolated enum Difficulty: String, Codable, CaseIterable, Identifiable, Sendable, Comparable {
    case easy, medium, hard, expert, evil, extreme

    var id: Self { self }

    /// The difficulty proposed when there are not enough recent wins to go by.
    static let fallback = Difficulty.hard

    var name: LocalizedStringResource {
        switch self {
        case .easy: "Facile"
        case .medium: "Medio"
        case .hard: "Difficile"
        case .expert: "Esperto"
        case .evil: "Diabolico"
        case .extreme: "Estremo"
        }
    }

    /// How many cells the puzzle gives.
    var givens: ClosedRange<Int> {
        switch self {
        case .easy: 38...38
        case .medium: 34...38
        case .hard: 28...33
        case .expert: 27...32
        case .evil: 24...28
        case .extreme: 22...25
        }
    }

    /// The most a correct cell is worth, when it comes within five seconds of the last one.
    /// The least is a tenth of it, and every five seconds take a tenth away.
    var maxPoints: Int {
        switch self {
        case .easy: 50
        case .medium: 150
        case .hard: 210
        case .expert: 230
        case .evil, .extreme: 250
        }
    }

    var minPoints: Int { maxPoints / 10 }

    /// The weights of the difficulties proposed after this one is the player's level.
    var proposalWeights: [Difficulty: Double] {
        switch self {
        case .easy: [.easy: 10, .medium: 70, .hard: 20]
        case .medium: [.medium: 65, .hard: 35]
        case .hard: [.medium: 10, .hard: 70, .expert: 20]
        case .expert: [.hard: 10, .expert: 70, .evil: 20]
        case .evil: [.expert: 10, .evil: 70, .extreme: 20]
        case .extreme: [.evil: 35, .extreme: 65]
        }
    }

    static func < (lhs: Self, rhs: Self) -> Bool {
        allCases.firstIndex(of: lhs)! < allCases.firstIndex(of: rhs)!
    }
}
