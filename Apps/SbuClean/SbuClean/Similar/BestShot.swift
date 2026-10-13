import Foundation

/// Picks the photo to keep in a group, as a suggestion the user can change.
///
/// The rules go in order, and a rule decides only when the difference is clear:
/// 1. a favourite wins;
/// 2. a photo the user edited wins;
/// 3. a better face capture quality wins (eyes open, looking at the camera), when both have faces;
/// 4. a clearly sharper photo wins;
/// 5. more pixels win;
/// 6. the older one wins, as the original of its copies.
nonisolated enum BestShot {
    /// Face quality differences below this are noise.
    static let faceQualityMargin: Float = 0.05
    /// One photo is clearly sharper when its score is this many times the other's.
    static let sharpnessRatio: Float = 1.15

    /// The identifier of the best candidate; `nil` for an empty list.
    static func best(of candidates: [ShotCandidate]) -> String? {
        guard var best = candidates.first else { return nil }

        for candidate in candidates.dropFirst() where isBetter(candidate, than: best) {
            best = candidate
        }
        return best.id
    }

    /// The members with the best first, the others in their original order.
    static func ordered(_ candidates: [ShotCandidate]) -> [String] {
        guard let best = best(of: candidates) else { return [] }

        return [best] + candidates.map(\.id).filter { $0 != best }
    }

    /// Whether `candidate` should be kept instead of `other`.
    static func isBetter(_ candidate: ShotCandidate, than other: ShotCandidate) -> Bool {
        if candidate.isFavorite != other.isFavorite {
            return candidate.isFavorite
        }
        if candidate.hasAdjustments != other.hasAdjustments {
            return candidate.hasAdjustments
        }
        if let face = candidate.faceQuality, let otherFace = other.faceQuality, abs(face - otherFace) > faceQualityMargin {
            return face > otherFace
        }
        if candidate.sharpness > other.sharpness * sharpnessRatio {
            return true
        }
        if other.sharpness > candidate.sharpness * sharpnessRatio {
            return false
        }
        if candidate.pixelCount != other.pixelCount {
            return candidate.pixelCount > other.pixelCount
        }
        if let date = candidate.date, let otherDate = other.date, date != otherDate {
            return date < otherDate
        }
        return false
    }
}
