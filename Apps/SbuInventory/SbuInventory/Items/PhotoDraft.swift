import Foundation

/// A photo in the item form: one the item already has (same id) or one just added.
nonisolated struct PhotoDraft: Identifiable, Equatable, Sendable {
    let id: UUID
    let data: Data
    let thumbnail: Data
}
