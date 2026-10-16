import Foundation

/// An app or an input on the TV, by the TV's own identifier and name. Shown as text with a
/// generic SF Symbol, never a logo (#351).
nonisolated struct TVShortcut: Codable, Hashable, Identifiable, Sendable {
    /// The TV's identifier: a Tizen app id, a webOS app id, a deep link, a Sony URI.
    let id: String
    let name: String
}
