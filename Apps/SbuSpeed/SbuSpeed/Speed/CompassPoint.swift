import Foundation

/// One of the eight points of the compass, for the course: 247° is south-west.
nonisolated enum CompassPoint: Int, CaseIterable, Sendable {
    case north, northEast, east, southEast, south, southWest, west, northWest

    /// The point whose 45° sector holds `degrees`, any value: north spans 337.5° to 22.5°.
    init(degrees: Double) {
        let sector = 360.0 / Double(Self.allCases.count)
        let normalized = (degrees.truncatingRemainder(dividingBy: 360) + 360).truncatingRemainder(dividingBy: 360)
        let index = Int((normalized + sector / 2) / sector) % Self.allCases.count
        self = Self.allCases[index]
    }

    /// The letters next to the degrees: "SO" in Italian, "SW" in English.
    var abbreviation: LocalizedStringResource {
        switch self {
        case .north: LocalizedStringResource("N", comment: "Compass point: north")
        case .northEast: LocalizedStringResource("NE", comment: "Compass point: north-east")
        case .east: LocalizedStringResource("E", comment: "Compass point: east")
        case .southEast: LocalizedStringResource("SE", comment: "Compass point: south-east")
        case .south: LocalizedStringResource("S", comment: "Compass point: south")
        case .southWest: LocalizedStringResource("SO", comment: "Compass point: south-west")
        case .west: LocalizedStringResource("O", comment: "Compass point: west")
        case .northWest: LocalizedStringResource("NO", comment: "Compass point: north-west")
        }
    }

    /// The name VoiceOver reads: "sud-ovest".
    var name: LocalizedStringResource {
        switch self {
        case .north: "nord"
        case .northEast: "nord-est"
        case .east: "est"
        case .southEast: "sud-est"
        case .south: "sud"
        case .southWest: "sud-ovest"
        case .west: "ovest"
        case .northWest: "nord-ovest"
        }
    }
}
