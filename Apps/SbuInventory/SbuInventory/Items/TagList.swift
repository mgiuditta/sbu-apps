/// Tags as the inventory keeps them: trimmed, no empty ones, each once whatever its case or accents.
nonisolated enum TagList {
    static func normalized(_ tags: [String]) -> [String] {
        var seen: Set<String> = []
        return tags.compactMap { tag in
            let trimmed = tag.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty, seen.insert(SearchKey.fold(trimmed)).inserted else { return nil }
            return trimmed
        }
    }

    /// The tags you already used that start with what you are typing, the ones already on the item left out.
    static func suggestions(for text: String, among all: [String], excluding current: [String]) -> [String] {
        let typed = SearchKey.fold(text)
        let taken = Set(current.map(SearchKey.fold))
        return normalized(all)
            .filter { !taken.contains(SearchKey.fold($0)) && (typed.isEmpty || SearchKey.fold($0).hasPrefix(typed)) }
            .sorted { $0.localizedStandardCompare($1) == .orderedAscending }
    }
}
