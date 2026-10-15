import Foundation

/// The altitude and the course of the latest fix, for the line under the figure; `nil` when the
/// fix cannot tell, and the screen shows a dash. Only the latest fix: nothing here is saved.
nonisolated struct NavigationReading: Equatable, Sendable {
    /// Altitudes less certain than this (metres) are not shown: the GPS altitude is coarse anyway.
    static let maxVerticalAccuracy = 50.0
    /// Courses less certain than this (degrees) are not shown: one point of the compass is 45°.
    static let maxCourseAccuracy = 45.0

    /// Metres above sea level.
    var altitude: Double?
    /// Degrees clockwise from true north, 0 up to 360.
    var course: Double?

    init(altitude: Double? = nil, course: Double? = nil) {
        self.altitude = altitude
        self.course = course
    }

    init(sample: SpeedSample) {
        if sample.verticalAccuracy >= 0, sample.verticalAccuracy <= Self.maxVerticalAccuracy {
            altitude = sample.altitude
        }
        // Standing still the GPS has no direction: the course only counts while moving.
        if sample.course >= 0, sample.courseAccuracy >= 0, sample.courseAccuracy <= Self.maxCourseAccuracy,
           sample.hasValidSpeed, sample.speed >= Trip.movingSpeed {
            course = sample.course
        }
    }

    /// The altitude in the unit of the speed: "122 m", "400 ft", or a dash.
    func altitudeText(unit: SpeedUnit, locale: Locale = .autoupdatingCurrent) -> String {
        guard let altitude else { return SpeedFigureStyle.noSpeed }
        return unit.altitudeText(meters: altitude, width: .abbreviated, locale: locale)
    }

    /// The altitude in words, for VoiceOver: "122 metri".
    func altitudeSpokenText(unit: SpeedUnit, locale: Locale = .autoupdatingCurrent) -> String {
        guard let altitude else { return String(localized: "Non disponibile", locale: locale) }
        return unit.altitudeText(meters: altitude, width: .wide, locale: locale)
    }

    /// The course in whole degrees with its compass point: "247° SO", or a dash.
    func courseText(locale: Locale = .autoupdatingCurrent) -> String {
        guard let course else { return SpeedFigureStyle.noSpeed }
        var point = CompassPoint(degrees: course).abbreviation
        point.locale = locale
        return "\(Self.degreesText(course, width: .narrow, locale: locale)) \(String(localized: point))"
    }

    /// The course in words, for VoiceOver: "247 gradi, sud-ovest".
    func courseSpokenText(locale: Locale = .autoupdatingCurrent) -> String {
        guard let course else { return String(localized: "Non disponibile", locale: locale) }
        var point = CompassPoint(degrees: course).name
        point.locale = locale
        return "\(Self.degreesText(course, width: .wide, locale: locale)), \(String(localized: point))"
    }

    /// Whole degrees from 0 to 359: 359.6 rounds to 0, as on a compass.
    private static func degreesText(_ degrees: Double, width: Measurement<UnitAngle>.FormatStyle.UnitWidth, locale: Locale) -> String {
        let whole = Int(degrees.rounded()) % 360
        return Measurement(value: Double(whole), unit: UnitAngle.degrees)
            .formatted(.measurement(width: width, numberFormatStyle: .number.precision(.fractionLength(0))).locale(locale))
    }
}
