import Foundation

/// Text folded for search: lowercase, no accents, single spaces. "Caffè Moka" and "caffe moka" fold the same.
nonisolated enum SearchKey {
    /// One key from every searchable part of an item, each folded and joined by a space.
    static func make(_ parts: [String]) -> String {
        parts.map(fold).filter { !$0.isEmpty }.joined(separator: " ")
    }

    static func fold(_ text: String) -> String {
        text.folding(options: [.caseInsensitive, .diacriticInsensitive, .widthInsensitive], locale: Locale(identifier: "en_US_POSIX"))
            .split(whereSeparator: \.isWhitespace)
            .joined(separator: " ")
    }
}
