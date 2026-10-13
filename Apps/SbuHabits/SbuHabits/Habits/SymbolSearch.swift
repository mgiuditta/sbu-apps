import Foundation

/// Finds habit symbols by what people type: every word of the query must start one of the
/// symbol's words, in Italian or English, ignoring case and accents.
nonisolated enum SymbolSearch {
    /// One group of the picker with the symbols it shows.
    typealias Section = (category: HabitSymbolCategory, symbols: [HabitSymbol])

    /// The symbols matching `query` in catalog order; all of them for a blank query.
    static func filter(_ symbols: [HabitSymbol], matching query: String) -> [HabitSymbol] {
        let words = terms(in: [query])
        guard words.isEmpty == false else { return symbols }
        return symbols.filter { symbol in
            words.allSatisfy { word in
                symbol.searchTerms.contains { $0.hasPrefix(word) }
            }
        }
    }

    /// The matches grouped by category, in category order, leaving out the empty groups.
    static func sections(of symbols: [HabitSymbol], matching query: String) -> [Section] {
        let matches = Dictionary(grouping: filter(symbols, matching: query), by: \.category)
        return HabitSymbolCategory.allCases.compactMap { category in
            matches[category].map { (category, $0) }
        }
    }

    /// The words in `texts`, lowercased and without accents, apostrophes and hyphens splitting
    /// them ("all'aperto" gives "all" and "aperto").
    static func terms(in texts: [String]) -> [String] {
        texts.flatMap { text in
            text.folding(options: [.caseInsensitive, .diacriticInsensitive, .widthInsensitive], locale: nil)
                .split { $0.isLetter == false && $0.isNumber == false }
                .map(String.init)
        }
    }
}
