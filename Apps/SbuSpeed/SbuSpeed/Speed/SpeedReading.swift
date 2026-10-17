import Foundation

/// One row of the card under the figure: a value of the trip or of the latest fix.
nonisolated struct SpeedReading: Identifiable, Sendable {
    let id: String
    let label: LocalizedStringResource
    /// What VoiceOver reads instead of `label`, when the label is an abbreviation like COG.
    var spokenLabel: LocalizedStringResource?
    let value: String
    /// What VoiceOver reads instead of `value`, when the value on screen reads badly aloud, like a clock.
    var spokenValue: String?

    /// The trip, then altitude and course: top and average speed, distance, moving time, altitude, course.
    /// With knots the course is COG, as on a chart plotter.
    static func readings(trip: Trip, navigation: NavigationReading, unit: SpeedUnit) -> [SpeedReading] {
        [
            SpeedReading(id: "top", label: "Massima", value: unit.speedText(metersPerSecond: trip.maxSpeed)),
            SpeedReading(id: "average", label: "Media", value: unit.speedText(metersPerSecond: trip.averageSpeed)),
            SpeedReading(id: "distance", label: "Distanza", value: unit.distanceText(meters: trip.distance)),
            SpeedReading(id: "time", label: "Durata", value: trip.movingTimeText(), spokenValue: trip.movingTimeSpokenText()),
            SpeedReading(
                id: "altitude",
                label: "Altitudine",
                value: navigation.altitudeText(unit: unit),
                spokenValue: navigation.altitudeSpokenText(unit: unit)
            ),
            SpeedReading(
                id: "course",
                label: unit == .knots ? "COG" : "Rotta",
                spokenLabel: unit == .knots ? "Rotta sul fondo" : nil,
                value: navigation.courseText(),
                spokenValue: navigation.courseSpokenText()
            ),
        ]
    }
}
