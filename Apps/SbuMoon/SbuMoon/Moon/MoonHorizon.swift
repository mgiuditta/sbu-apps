import Foundation

/// The moon's altitude above the horizon of a place, and the day's rise and set worked out from
/// it (Meeus chapters 12, 13 and 15): the upper limb touching the horizon, with the usual 34′ of
/// refraction and the parallax of the moon's distance at that moment.
nonisolated enum MoonHorizon {
    /// How often the altitude is sampled to find a crossing; the moon cannot rise and set again
    /// within this time anywhere people live.
    static let step: TimeInterval = 600

    /// The moon's geocentric altitude, in degrees, and the altitude its centre has when its upper
    /// limb touches the horizon (Meeus 15, h₀ = 0.7275 π − 0°34′).
    static func altitude(at date: Date, coordinates: Coordinates) -> (altitude: Double, horizon: Double) {
        let position = LunarPosition(at: date)
        let hourAngle = apparentSiderealTime(at: date, nutation: position.nutationInLongitude, obliquity: position.obliquity)
            + coordinates.longitude - position.rightAscension
        let sinAltitude = MoonAstronomy.sine(coordinates.latitude) * MoonAstronomy.sine(position.declination)
            + MoonAstronomy.cosine(coordinates.latitude) * MoonAstronomy.cosine(position.declination) * MoonAstronomy.cosine(hourAngle)
        let altitude = asin(max(-1, min(1, sinAltitude))) * 180 / .pi
        return (altitude, 0.7275 * position.parallax - 34.0 / 60)
    }

    /// Rise and set on the calendar day that contains `date`, in `calendar`'s time zone.
    static func riseSet(on date: Date, at coordinates: Coordinates, calendar: Calendar) -> MoonRiseSet {
        let start = calendar.startOfDay(for: date)
        let end = calendar.date(byAdding: .day, value: 1, to: start) ?? start.addingTimeInterval(86_400)

        var rise: Date?
        var set: Date?
        var previousTime = start
        var previous = height(at: start, coordinates: coordinates)
        let isUpAtStart = previous > 0

        while previousTime < end {
            let time = min(previousTime.addingTimeInterval(step), end)
            let current = height(at: time, coordinates: coordinates)
            if (previous <= 0) != (current <= 0) {
                let crossing = refine(from: previousTime, to: time, coordinates: coordinates)
                // Only crossings inside the day: the end instant belongs to the next one.
                if crossing < end {
                    if current > 0 {
                        rise = rise ?? crossing
                    } else {
                        set = set ?? crossing
                    }
                }
            }
            previousTime = time
            previous = current
        }

        if rise == nil && set == nil {
            return isUpAtStart ? .aboveAllDay : .belowAllDay
        }
        return .crosses(rise: rise, set: set)
    }

    /// Altitude above the rise and set altitude: positive while the moon is up.
    private static func height(at date: Date, coordinates: Coordinates) -> Double {
        let sample = altitude(at: date, coordinates: coordinates)
        return sample.altitude - sample.horizon
    }

    /// Halves the interval around a crossing down to a second.
    private static func refine(from start: Date, to end: Date, coordinates: Coordinates) -> Date {
        var low = start
        var high = end
        let isRising = height(at: start, coordinates: coordinates) <= 0
        while high.timeIntervalSince(low) > 1 {
            let middle = low.addingTimeInterval(high.timeIntervalSince(low) / 2)
            let isUp = height(at: middle, coordinates: coordinates) > 0
            if isUp == isRising {
                high = middle
            } else {
                low = middle
            }
        }
        return low.addingTimeInterval(high.timeIntervalSince(low) / 2)
    }

    /// Apparent sidereal time at Greenwich, in degrees (Meeus 12.4 plus the equation of the equinoxes).
    static func apparentSiderealTime(at date: Date, nutation: Double, obliquity: Double) -> Double {
        let julianDay = MoonAstronomy.julianDay(of: date)
        let t = (julianDay - 2_451_545) / 36_525
        let mean = 280.46061837 + 360.98564736629 * (julianDay - 2_451_545) + 0.000387933 * t * t - t * t * t / 38_710_000
        return LunarPosition.normalized(mean + nutation * MoonAstronomy.cosine(obliquity))
    }
}
