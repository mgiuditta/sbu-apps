import Foundation

/// A folder's place written out: "Casa › Garage › Scatola 3".
nonisolated enum FolderPath {
    /// The separator on screen.
    static let separator = " › "

    /// The path for display, or `root` at the top of the inventory.
    static func text(_ names: [String], root: String) -> String {
        names.isEmpty ? root : names.joined(separator: separator)
    }
}
