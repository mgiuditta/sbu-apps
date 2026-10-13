import Foundation

/// An SF Symbol a habit can wear, with the name VoiceOver reads, its group in the picker and the
/// words that find it in both languages. The list is in `HabitSymbol+Catalog.swift`.
nonisolated struct HabitSymbol: Identifiable, Sendable {
    /// SF Symbol name, the id saved with a habit: never rename or drop one.
    let id: String
    let name: LocalizedStringResource
    let category: HabitSymbolCategory
    /// The Italian and English names and the keywords, folded for the search.
    let searchTerms: [String]

    /// - Parameters:
    ///   - english: the English name, as in `Localizable.xcstrings`, so the search finds it in either language.
    ///   - keywords: more words, Italian and English, separated by spaces.
    init(_ id: String, _ name: LocalizedStringResource, _ english: String, _ category: HabitSymbolCategory, _ keywords: String = "") {
        self.id = id
        self.name = name
        self.category = category
        searchTerms = SymbolSearch.terms(in: [name.key, english, keywords])
    }

    /// The catalog entry for a saved symbol name, if it is one.
    static func named(_ id: String) -> HabitSymbol? {
        index[id]
    }

    private static let index = Dictionary(uniqueKeysWithValues: all.map { ($0.id, $0) })
}
