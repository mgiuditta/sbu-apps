import Foundation

/// A city from the list bundled with the app: a name in Italian and English, where it is and its clock.
nonisolated struct City: Decodable, Identifiable, Equatable, Sendable {
    /// Stable key saved with the chosen place, such as "rome".
    var id: String
    var it: String
    var en: String
    var latitude: Double
    var longitude: Double
    /// The IANA identifier of the city's clock, such as "America/New_York".
    var timeZone: String

    /// The city's clock; the iPhone's if the identifier were ever unknown.
    var zone: TimeZone {
        TimeZone(identifier: timeZone) ?? .current
    }

    var coordinates: Coordinates {
        Coordinates(latitude: latitude, longitude: longitude)
    }

    /// The name in the app's language: Italian for Italian, English otherwise.
    func name(locale: Locale = .current) -> String {
        locale.language.languageCode == .italian ? it : en
    }
}
