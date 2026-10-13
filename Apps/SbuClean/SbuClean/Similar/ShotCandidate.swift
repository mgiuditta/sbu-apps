import Foundation

/// What the best-shot choice compares about one member of a group.
nonisolated struct ShotCandidate: Equatable, Sendable {
    var id: String
    var isFavorite = false
    var hasAdjustments = false
    /// The best face capture quality, 0 to 1; `nil` without faces.
    var faceQuality: Float?
    var sharpness: Float = 0
    var pixelCount = 0
    var date: Date?
}
