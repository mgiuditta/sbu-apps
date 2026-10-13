import Foundation

/// The cities bundled in `cities.json`: Italian regional capitals, European capitals and the
/// largest US cities. A place without GPS or network, never geocoded.
nonisolated enum CityCatalog {
    /// Every city, in the file's order.
    static let all: [City] = load(from: .main)

    static func load(from bundle: Bundle) -> [City] {
        guard let url = bundle.url(forResource: "cities", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let cities = try? JSONDecoder().decode([City].self, from: data)
        else { return [] }
        return cities
    }

    static func city(id: String) -> City? {
        all.first { $0.id == id }
    }

    /// Cities whose name contains `query`, ignoring case and accents, sorted by name.
    static func cities(matching query: String, in cities: [City] = all, locale: Locale = .current) -> [City] {
        let trimmed = query.trimmingCharacters(in: .whitespaces)
        let matches = trimmed.isEmpty ? cities : cities.filter { city in
            [city.name(locale: locale), city.it, city.en].contains {
                $0.range(of: trimmed, options: [.caseInsensitive, .diacriticInsensitive], locale: locale) != nil
            }
        }
        return matches.sorted { $0.name(locale: locale).compare($1.name(locale: locale), locale: locale) == .orderedAscending }
    }
}
