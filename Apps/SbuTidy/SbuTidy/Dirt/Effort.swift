import Foundation

/// How much work a chore is, from one to three dots as in Tody.
nonisolated enum Effort: Int, Codable, CaseIterable, Comparable, Sendable {
    case light = 1
    case medium = 2
    case heavy = 3

    /// Any stored number becomes the nearest effort: 0 or less is light, 4 or more heavy.
    init(clamping value: Int) {
        self = Effort(rawValue: min(max(value, 1), 3)) ?? .light
    }

    static func < (lhs: Effort, rhs: Effort) -> Bool { lhs.rawValue < rhs.rawValue }

    var name: LocalizedStringResource {
        switch self {
        case .light: "Leggero"
        case .medium: "Medio"
        case .heavy: "Impegnativo"
        }
    }
}
