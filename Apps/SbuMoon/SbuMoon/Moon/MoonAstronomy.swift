import Foundation

/// The moon's phases and illuminated fraction, computed offline from Jean Meeus,
/// *Astronomical Algorithms* (2nd ed.): chapter 49 for the phase instants (error of seconds
/// to a minute or two), formula 48.4 for the illuminated fraction (error under 0.2%).
nonisolated enum MoonAstronomy {
    /// Mean length of a lunation, in days.
    static let synodicMonth = 29.530588861
    /// Julian Day of the Unix epoch, 1970-01-01 00:00 UT.
    private static let unixEpochJulianDay = 2_440_587.5
    /// Julian Day of J2000.0, 2000-01-01 12:00 TT.
    private static let j2000 = 2_451_545.0
    /// Mean new moon of lunation 0, 2000-01-06 (Meeus 49.1).
    private static let firstNewMoon = 2_451_550.097_66

    // MARK: Time

    /// Julian Day (UT) of a date.
    static func julianDay(of date: Date) -> Double {
        date.timeIntervalSince1970 / 86_400 + unixEpochJulianDay
    }

    /// The date of a Julian Day (UT).
    static func date(julianDay: Double) -> Date {
        Date(timeIntervalSince1970: (julianDay - unixEpochJulianDay) * 86_400)
    }

    /// ΔT = TT − UT in seconds, from the Espenak–Meeus polynomials (NASA, 2006).
    static func deltaT(julianDay: Double) -> Double {
        let year = 2000 + (julianDay - j2000) / 365.25
        let t = year - 2000
        let u = (year - 1820) / 100
        switch year {
        case 1986..<2005:
            return 63.86 + 0.3345 * t - 0.060374 * pow(t, 2) + 0.0017275 * pow(t, 3)
                + 0.000651814 * pow(t, 4) + 0.00002373599 * pow(t, 5)
        case 2005..<2050:
            return 62.92 + 0.32217 * t + 0.005589 * pow(t, 2)
        case 2050..<2150:
            return -20 + 32 * pow(u, 2) - 0.5628 * (2150 - year)
        default:
            return -20 + 32 * pow(u, 2)
        }
    }

    // MARK: Illumination

    /// Fraction of the moon's disc lit by the sun at a date, from 0 (new) to 1 (full).
    static func illuminatedFraction(at date: Date) -> Double {
        let julianDay = julianDay(of: date)
        let t = (julianDay + deltaT(julianDay: julianDay) / 86_400 - j2000) / 36_525
        // Meeus 47.2, 47.3, 47.4: mean elongation, sun's and moon's mean anomaly, in degrees.
        let d = 297.8501921 + 445_267.1114034 * t - 0.0018819 * t * t + pow(t, 3) / 545_868 - pow(t, 4) / 113_065_000
        let m = 357.5291092 + 35_999.0502909 * t - 0.0001536 * t * t + pow(t, 3) / 24_490_000
        let mPrime = 134.9633964 + 477_198.8675055 * t + 0.0087414 * t * t + pow(t, 3) / 69_699 - pow(t, 4) / 14_712_000
        // Meeus 48.4: phase angle.
        let i = 180 - d
            - 6.289 * sine(mPrime)
            + 2.100 * sine(m)
            - 1.274 * sine(2 * d - mPrime)
            - 0.658 * sine(2 * d)
            - 0.214 * sine(2 * mPrime)
            - 0.110 * sine(d)
        return (1 + cosine(i)) / 2
    }

    // MARK: Phases

    /// The lunation whose new moon comes at or just before a date (lunation 0: January 2000).
    static func lunation(containing date: Date) -> Int {
        Int(((julianDay(of: date) - firstNewMoon) / synodicMonth).rounded(.down))
    }

    /// The instant of a principal phase in a lunation (Meeus chapter 49).
    static func instant(of phase: PrincipalPhase, lunation: Int) -> Date {
        let k = Double(lunation) + phase.lunationOffset
        let t = k / 1236.85
        let t2 = t * t, t3 = t2 * t, t4 = t3 * t

        var jde = firstNewMoon + synodicMonth * k + 0.00015437 * t2 - 0.000000150 * t3 + 0.00000000073 * t4
        let e = 1 - 0.002516 * t - 0.0000074 * t2
        let m = 2.5534 + 29.10535670 * k - 0.0000014 * t2 - 0.00000011 * t3
        let mPrime = 201.5643 + 385.81693528 * k + 0.0107582 * t2 + 0.00001238 * t3 - 0.000000058 * t4
        let f = 160.7108 + 390.67050284 * k - 0.0016118 * t2 - 0.00000227 * t3 + 0.000000011 * t4
        let omega = 124.7746 - 1.56375588 * k + 0.0020672 * t2 + 0.00000215 * t3

        let arguments = PhaseArguments(e: e, m: m, mPrime: mPrime, f: f, omega: omega)
        switch phase {
        case .new: jde += arguments.newMoonCorrection
        case .full: jde += arguments.fullMoonCorrection
        case .firstQuarter: jde += arguments.quarterCorrection + arguments.quarterW
        case .lastQuarter: jde += arguments.quarterCorrection - arguments.quarterW
        }
        jde += planetaryCorrection(k: k, t2: t2)

        let julianDay = jde - deltaT(julianDay: jde) / 86_400
        return date(julianDay: julianDay)
    }

    /// The first instant of a principal phase strictly after a date.
    static func next(_ phase: PrincipalPhase, after date: Date) -> Date {
        var lunation = lunation(containing: date) - 1
        while true {
            let instant = instant(of: phase, lunation: lunation)
            if instant > date {
                return instant
            }
            lunation += 1
        }
    }

    /// Every principal phase from two lunations before a date to two after, in order.
    static func events(around date: Date) -> [PhaseEvent] {
        let center = lunation(containing: date)
        return (center - 2...center + 2).flatMap { lunation in
            PrincipalPhase.allCases.map { PhaseEvent(phase: $0, date: instant(of: $0, lunation: lunation)) }
        }
    }

    /// Additional corrections for all phases, from the planetary arguments A1–A14.
    private static func planetaryCorrection(k: Double, t2: Double) -> Double {
        let terms: [(coefficient: Double, argument: Double)] = [
            (0.000325, 299.77 + 0.107408 * k - 0.009173 * t2),
            (0.000165, 251.88 + 0.016321 * k),
            (0.000164, 251.83 + 26.651886 * k),
            (0.000126, 349.42 + 36.412478 * k),
            (0.000110, 84.66 + 18.206239 * k),
            (0.000062, 141.74 + 53.303771 * k),
            (0.000060, 207.14 + 2.453732 * k),
            (0.000056, 154.84 + 7.306860 * k),
            (0.000047, 34.52 + 27.261239 * k),
            (0.000042, 207.19 + 0.121824 * k),
            (0.000040, 291.34 + 1.844379 * k),
            (0.000037, 161.72 + 24.198154 * k),
            (0.000035, 239.56 + 25.513099 * k),
            (0.000023, 331.55 + 3.592518 * k),
        ]
        return terms.reduce(0) { $0 + $1.coefficient * sine($1.argument) }
    }

    static func sine(_ degrees: Double) -> Double {
        sin(degrees * .pi / 180)
    }

    static func cosine(_ degrees: Double) -> Double {
        cos(degrees * .pi / 180)
    }
}
