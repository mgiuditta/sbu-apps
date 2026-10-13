import Foundation

/// The icons the user can pick for the owner of an Abitudine condivisa, as Streaks offers them:
/// the person symbol first, then a row of system emoji. Kept only on this iPhone.
nonisolated enum OwnerEmoji {
    /// The SF Symbol for the owner when no emoji is picked.
    static let personSymbol = "person.fill"

    /// The emoji offered after the person symbol, in order.
    static let choices = ["😎", "😀", "🙃", "🤩", "🥳", "💪", "🌱", "❤️", "⭐️", "🔥"]

    /// An emoji kept only if it is one of `choices`; anything else falls back to the person symbol.
    static func validated(_ emoji: String?) -> String? {
        emoji.flatMap { choices.contains($0) ? $0 : nil }
    }
}
