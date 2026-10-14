import Foundation

/// A known service you can add in one tap: its name, category and usual cycle. No prices, no logos.
nonisolated struct CatalogService: Decodable, Hashable, Identifiable, Sendable {
    /// Also the 1.0's `icon_slug`, so a migrated subscription finds its service.
    let id: String
    let name: String
    let category: BuiltInCategory
    let cycle: BillingCycle

    private enum CodingKeys: String, CodingKey {
        case id, name, category, cycle
    }

    init(id: String, name: String, category: BuiltInCategory, cycle: BillingCycle) {
        self.id = id
        self.name = name
        self.category = category
        self.cycle = cycle
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        category = try container.decode(BuiltInCategory.self, forKey: .category)
        cycle = switch try container.decode(String.self, forKey: .cycle) {
        case "weekly": .weekly
        case "quarterly": .every(3, .month)
        case "yearly": .yearly
        default: .monthly
        }
    }

    static let bundled: [CatalogService] = {
        // ponytail: a broken bundled file is a build bug, caught by the tests; an empty catalog still lets you add your own.
        guard let url = Bundle.main.url(forResource: "Catalog", withExtension: "json"),
              let data = try? Data(contentsOf: url) else { return [] }
        return (try? JSONDecoder().decode([CatalogService].self, from: data)) ?? []
    }()

    /// The services whose name contains `query`, ignoring case and accents; all of them for an empty query.
    static func matching(_ query: String, in services: [CatalogService] = bundled) -> [CatalogService] {
        let query = query.trimmingCharacters(in: .whitespaces)
        guard !query.isEmpty else { return services }
        return services.filter { $0.name.range(of: query, options: [.caseInsensitive, .diacriticInsensitive]) != nil }
    }
}
