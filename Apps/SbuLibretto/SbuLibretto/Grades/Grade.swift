import Foundation

/// An Italian exam grade: a mark from 18 to 30, or 30 cum laude.
///
/// What cum laude is worth in an average changes between universities (30 at PoliMi and UniBo,
/// 31 at Sapienza, 33 at UniMi), so it is not a number here: `value(cumLaudeValue:)` turns it into one.
nonisolated enum Grade: Hashable, Comparable, Codable, Sendable {
    /// A passing mark, from `lowest` to `highest`.
    case mark(Int)
    /// 30 e lode.
    case cumLaude

    /// The lowest passing mark.
    static let lowest = 18
    /// The highest mark before cum laude.
    static let highest = 30

    /// Every grade from 18 up to 30 cum laude.
    static let ascending: [Grade] = (lowest...highest).map(Grade.mark) + [.cumLaude]

    /// Every grade from 30 cum laude down to 18, as the simulator lists them.
    static let descending: [Grade] = ascending.reversed()

    /// The grade for a mark, or `nil` outside 18...30.
    init?(mark: Int, cumLaude: Bool = false) {
        guard (Self.lowest...Self.highest).contains(mark) else { return nil }
        if cumLaude {
            guard mark == Self.highest else { return nil }
            self = .cumLaude
        } else {
            self = .mark(mark)
        }
    }

    /// The mark as an integer: 30 for cum laude.
    var mark: Int {
        switch self {
        case let .mark(mark): mark
        case .cumLaude: Self.highest
        }
    }

    var isCumLaude: Bool {
        self == .cumLaude
    }

    /// The number this grade counts as in an average.
    func value(cumLaudeValue: Double) -> Double {
        switch self {
        case let .mark(mark): Double(mark)
        case .cumLaude: cumLaudeValue
        }
    }

    /// The short form shown in lists: "27", "30L".
    var shortText: String {
        isCumLaude ? "30L" : String(mark)
    }

    static func < (lhs: Grade, rhs: Grade) -> Bool {
        switch (lhs, rhs) {
        case let (.mark(left), .mark(right)): left < right
        case (.mark, .cumLaude): true
        case (.cumLaude, _): false
        }
    }
}
