import Foundation

/// Finds Modelli by what people type, in every tab: as `SymbolSearch` does, every word of the
/// query must start one of the template's words, in Italian or English, ignoring case and accents.
nonisolated enum TemplateSearch {
    /// One tab with the Modelli it finds.
    typealias Section = (category: HabitTemplateCategory, templates: [HabitTemplate])

    /// The templates matching `query` in catalog order; none for a blank query, which is no search.
    static func filter(_ templates: [HabitTemplate], matching query: String) -> [HabitTemplate] {
        let words = SymbolSearch.terms(in: [query])
        guard words.isEmpty == false else { return [] }
        return templates.filter { template in
            words.allSatisfy { word in
                template.searchTerms.contains { $0.hasPrefix(word) }
            }
        }
    }

    /// The matches grouped by tab, in tab order, leaving out the empty tabs.
    static func sections(of templates: [HabitTemplate], matching query: String) -> [Section] {
        let matches = Dictionary(grouping: filter(templates, matching: query), by: \.category)
        return HabitTemplateCategory.allCases.compactMap { category in
            matches[category].map { (category, $0) }
        }
    }
}
