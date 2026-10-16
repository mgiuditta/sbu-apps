import Foundation

/// How the base for the degree grade is rounded.
nonisolated enum GradeRounding: String, CaseIterable, Codable, Sendable {
    /// Kept with its decimals.
    case none
    /// To the nearest whole number, .50 up, as PoliMi does.
    case nearest
    /// Always up to the next whole number.
    case up
    /// Always down: the decimals are dropped.
    case down

    /// Rounds a base. Float noise below a millionth is cleared first, so 100.4999999 from the
    /// arithmetic is 100.5, as the student computes it by hand.
    func apply(to value: Double) -> Double {
        guard value.isFinite else { return value }
        let clean = (value * 1_000_000).rounded() / 1_000_000
        return switch self {
        case .none: clean
        case .nearest: clean.rounded(.toNearestOrAwayFromZero)
        case .up: clean.rounded(.up)
        case .down: clean.rounded(.down)
        }
    }
}
