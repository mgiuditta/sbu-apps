/// What you typed in the search field, split into words: an item matches when its key holds every word,
/// in any order, so "garage trapano" finds "Trapano" with the note "in garage".
nonisolated struct SearchQuery: Sendable {
    let words: [String]

    init(_ text: String) {
        words = SearchKey.fold(text).split(separator: " ").map(String.init)
    }

    var isEmpty: Bool { words.isEmpty }

    func matches(_ key: String) -> Bool {
        words.allSatisfy { key.contains($0) }
    }
}
