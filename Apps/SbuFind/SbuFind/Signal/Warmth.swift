import Foundation

/// The hot and cold game, in four words: how near the device sounds.
nonisolated enum Warmth: Int, CaseIterable, Comparable, Codable, Sendable {
    case cold
    case warm
    case hot
    case veryClose

    /// The proximity where each word begins, going up.
    static func lowerBound(of warmth: Warmth) -> Int {
        switch warmth {
        case .cold: 0
        case .warm: 35
        case .hot: 60
        case .veryClose: 80
        }
    }

    /// The word for a proximity, without memory of the previous one: for the list.
    init(proximity: Proximity) {
        self = Self.allCases.last { proximity.value >= Self.lowerBound(of: $0) } ?? .cold
    }

    var name: LocalizedStringResource {
        switch self {
        case .cold: "Freddo"
        case .warm: "Tiepido"
        case .hot: "Caldo"
        case .veryClose: "Qui vicino"
        }
    }

    var systemImage: String {
        switch self {
        case .cold: "thermometer.snowflake"
        case .warm: "thermometer.low"
        case .hot: "thermometer.medium"
        case .veryClose: "thermometer.high"
        }
    }

    static func < (lhs: Warmth, rhs: Warmth) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}
