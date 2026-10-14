import Foundation

/// A place from a `geo:latitude,longitude` code.
nonisolated struct GeoPoint: Equatable, Sendable {
    var latitude: Double
    var longitude: Double

    init?(latitude: Double, longitude: Double) {
        guard (-90...90).contains(latitude), (-180...180).contains(longitude) else { return nil }
        self.latitude = latitude
        self.longitude = longitude
    }

    init?(code: String) {
        guard code.lowercased().hasPrefix("geo:") else { return nil }
        // geo:45.4642,9.19,120?q=… : altitude and query are dropped.
        let coordinates = code.dropFirst(4).prefix { $0 != "?" && $0 != ";" }.split(separator: ",")
        guard coordinates.count >= 2,
              let latitude = Double(coordinates[0].trimmingCharacters(in: .whitespaces)),
              let longitude = Double(coordinates[1].trimmingCharacters(in: .whitespaces))
        else { return nil }
        self.init(latitude: latitude, longitude: longitude)
    }

    var code: String { "geo:\(latitude),\(longitude)" }

    /// Apple Maps, which opens the Maps app: a link to the user's own app, not a call the app makes.
    var mapsURL: URL? {
        URL(string: "https://maps.apple.com/?ll=\(latitude),\(longitude)&q=\(latitude),\(longitude)")
    }
}
