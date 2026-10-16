import CoreGraphics

/// A straight line of the grid, from one point to another.
nonisolated struct GridSegment: Equatable, Sendable {
    let start: CGPoint
    let end: CGPoint
}
