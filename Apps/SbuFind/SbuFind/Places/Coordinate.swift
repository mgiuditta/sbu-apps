import Foundation

/// Where the iPhone was, as Core Location measured it.
nonisolated struct Coordinate: Codable, Equatable, Sendable {
    let latitude: Double
    let longitude: Double
    /// Radius of uncertainty in metres.
    let accuracy: Double
    let date: Date
}
