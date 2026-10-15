import Foundation

/// A photo ready to keep: the image upright and at most 2048 px, and its thumbnail for lists.
nonisolated struct ProcessedPhoto: Sendable, Equatable {
    let data: Data
    let thumbnail: Data
}
