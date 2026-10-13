import Foundation

/// Where the moon is seen from the centre of the Earth at an instant: apparent ecliptic and
/// equatorial coordinates in degrees and the distance in kilometres, from the periodic terms of
/// Meeus chapter 47 (error of about 10″ in longitude) and the short nutation of chapter 22.
nonisolated struct LunarPosition: Equatable, Sendable {
    /// Apparent geocentric ecliptic longitude, λ, with nutation.
    var longitude: Double
    /// Geocentric ecliptic latitude, β.
    var latitude: Double
    /// Distance between the centres of the Earth and the moon, Δ.
    var distance: Double
    /// True obliquity of the ecliptic, ε.
    var obliquity: Double
    /// Nutation in longitude, Δψ, in degrees.
    var nutationInLongitude: Double

    /// Right ascension, α, from 0 to 360 (Meeus 13.3).
    var rightAscension: Double {
        let alpha = atan2(
            MoonAstronomy.sine(longitude) * MoonAstronomy.cosine(obliquity)
                - tan(latitude * .pi / 180) * MoonAstronomy.sine(obliquity),
            MoonAstronomy.cosine(longitude)
        ) * 180 / .pi
        return Self.normalized(alpha)
    }

    /// Declination, δ (Meeus 13.4).
    var declination: Double {
        asin(
            MoonAstronomy.sine(latitude) * MoonAstronomy.cosine(obliquity)
                + MoonAstronomy.cosine(latitude) * MoonAstronomy.sine(obliquity) * MoonAstronomy.sine(longitude)
        ) * 180 / .pi
    }

    /// Equatorial horizontal parallax, π, in degrees.
    var parallax: Double {
        asin(6_378.14 / distance) * 180 / .pi
    }

    /// The position at `t` Julian centuries of Terrestrial Time from J2000.0.
    init(julianCenturies t: Double) {
        let a = LunarArguments(julianCenturies: t)
        let t2 = t * t, t3 = t2 * t, t4 = t3 * t
        let meanLongitude = 218.3164477 + 481_267.88123421 * t - 0.0015786 * t2 + t3 / 538_841 - t4 / 65_194_000
        let a1 = 119.75 + 131.849 * t
        let a2 = 53.09 + 479_264.290 * t
        let a3 = 313.45 + 481_266.484 * t

        var sumL = Self.longitudeTerms.reduce(0.0) { $0 + $1.value(a, MoonAstronomy.sine) }
        sumL += 3_958 * MoonAstronomy.sine(a1) + 1_962 * MoonAstronomy.sine(meanLongitude - a.latitude) + 318 * MoonAstronomy.sine(a2)

        var sumB = Self.latitudeTerms.reduce(0.0) { $0 + $1.value(a, MoonAstronomy.sine) }
        sumB += -2_235 * MoonAstronomy.sine(meanLongitude)
            + 382 * MoonAstronomy.sine(a3)
            + 175 * MoonAstronomy.sine(a1 - a.latitude)
            + 175 * MoonAstronomy.sine(a1 + a.latitude)
            + 127 * MoonAstronomy.sine(meanLongitude - a.moonAnomaly)
            - 115 * MoonAstronomy.sine(meanLongitude + a.moonAnomaly)

        // Nutation and obliquity, to 0.5″ and 0.1″ (Meeus chapter 22).
        let omega = 125.04452 - 1_934.136261 * t
        let sunLongitude = 280.4665 + 36_000.7698 * t
        let deltaPsi = (-17.20 * MoonAstronomy.sine(omega) - 1.32 * MoonAstronomy.sine(2 * sunLongitude)
            - 0.23 * MoonAstronomy.sine(2 * meanLongitude) + 0.21 * MoonAstronomy.sine(2 * omega)) / 3_600
        let deltaEpsilon = (9.20 * MoonAstronomy.cosine(omega) + 0.57 * MoonAstronomy.cosine(2 * sunLongitude)
            + 0.10 * MoonAstronomy.cosine(2 * meanLongitude) - 0.09 * MoonAstronomy.cosine(2 * omega)) / 3_600
        let meanObliquity = 23.439_291_111 - (46.8150 * t + 0.00059 * t2 - 0.001813 * t3) / 3_600

        longitude = Self.normalized(meanLongitude + sumL / 1_000_000 + deltaPsi)
        latitude = sumB / 1_000_000
        distance = MoonDistance.kilometres(arguments: a)
        obliquity = meanObliquity + deltaEpsilon
        nutationInLongitude = deltaPsi
    }

    /// The position at an instant.
    init(at date: Date) {
        self.init(julianCenturies: MoonAstronomy.julianCenturies(at: date))
    }

    static func normalized(_ degrees: Double) -> Double {
        let angle = degrees.truncatingRemainder(dividingBy: 360)
        return angle < 0 ? angle + 360 : angle
    }

    // MARK: Periodic terms

    /// One periodic term: multiples of D, M, M′ and F, and the coefficient in 0.000001°.
    private struct Term {
        var d: Double
        var m: Double
        var mPrime: Double
        var f: Double
        var coefficient: Double

        init(_ d: Double, _ m: Double, _ mPrime: Double, _ f: Double, _ coefficient: Double) {
            self.d = d
            self.m = m
            self.mPrime = mPrime
            self.f = f
            self.coefficient = coefficient
        }

        func value(_ a: LunarArguments, _ function: (Double) -> Double) -> Double {
            let angle = d * a.elongation + m * a.sunAnomaly + mPrime * a.moonAnomaly + f * a.latitude
            // Terms with M shrink with the eccentricity of the Earth's orbit, once per multiple.
            return coefficient * pow(a.eccentricity, abs(m)) * function(angle)
        }
    }

    /// Σl, the sine terms of table 47.A.
    private static let longitudeTerms: [Term] = [
        Term(0, 0, 1, 0, 6_288_774), Term(2, 0, -1, 0, 1_274_027), Term(2, 0, 0, 0, 658_314),
        Term(0, 0, 2, 0, 213_618), Term(0, 1, 0, 0, -185_116), Term(0, 0, 0, 2, -114_332),
        Term(2, 0, -2, 0, 58_793), Term(2, -1, -1, 0, 57_066), Term(2, 0, 1, 0, 53_322),
        Term(2, -1, 0, 0, 45_758), Term(0, 1, -1, 0, -40_923), Term(1, 0, 0, 0, -34_720),
        Term(0, 1, 1, 0, -30_383), Term(2, 0, 0, -2, 15_327), Term(0, 0, 1, 2, -12_528),
        Term(0, 0, 1, -2, 10_980), Term(4, 0, -1, 0, 10_675), Term(0, 0, 3, 0, 10_034),
        Term(4, 0, -2, 0, 8_548), Term(2, 1, -1, 0, -7_888), Term(2, 1, 0, 0, -6_766),
        Term(1, 0, -1, 0, -5_163), Term(1, 1, 0, 0, 4_987), Term(2, -1, 1, 0, 4_036),
        Term(2, 0, 2, 0, 3_994), Term(4, 0, 0, 0, 3_861), Term(2, 0, -3, 0, 3_665),
        Term(0, 1, -2, 0, -2_689), Term(2, 0, -1, 2, -2_602), Term(2, -1, -2, 0, 2_390),
        Term(1, 0, 1, 0, -2_348), Term(2, -2, 0, 0, 2_236), Term(0, 1, 2, 0, -2_120),
        Term(0, 2, 0, 0, -2_069), Term(2, -2, -1, 0, 2_048), Term(2, 0, 1, -2, -1_773),
        Term(2, 0, 0, 2, -1_595), Term(4, -1, -1, 0, 1_215), Term(0, 0, 2, 2, -1_110),
        Term(3, 0, -1, 0, -892), Term(2, 1, 1, 0, -810), Term(4, -1, -2, 0, 759),
        Term(0, 2, -1, 0, -713), Term(2, 2, -1, 0, -700), Term(2, 1, -2, 0, 691),
        Term(2, -1, 0, -2, 596), Term(4, 0, 1, 0, 549), Term(0, 0, 4, 0, 537),
        Term(4, -1, 0, 0, 520), Term(1, 0, -2, 0, -487), Term(2, 1, 0, -2, -399),
        Term(0, 0, 2, -2, -381), Term(1, 1, 1, 0, 351), Term(3, 0, -2, 0, -340),
        Term(4, 0, -3, 0, 330), Term(2, -1, 2, 0, 327), Term(0, 2, 1, 0, -323),
        Term(1, 1, -1, 0, 299), Term(2, 0, 3, 0, 294),
    ]

    /// Σb, the sine terms of table 47.B.
    private static let latitudeTerms: [Term] = [
        Term(0, 0, 0, 1, 5_128_122), Term(0, 0, 1, 1, 280_602), Term(0, 0, 1, -1, 277_693),
        Term(2, 0, 0, -1, 173_237), Term(2, 0, -1, 1, 55_413), Term(2, 0, -1, -1, 46_271),
        Term(2, 0, 0, 1, 32_573), Term(0, 0, 2, 1, 17_198), Term(2, 0, 1, -1, 9_266),
        Term(0, 0, 2, -1, 8_822), Term(2, -1, 0, -1, 8_216), Term(2, 0, -2, -1, 4_324),
        Term(2, 0, 1, 1, 4_200), Term(2, 1, 0, -1, -3_359), Term(2, -1, -1, 1, 2_463),
        Term(2, -1, 0, 1, 2_211), Term(2, -1, -1, -1, 2_065), Term(0, 1, -1, -1, -1_870),
        Term(4, 0, -1, -1, 1_828), Term(0, 1, 0, 1, -1_794), Term(0, 0, 0, 3, -1_749),
        Term(0, 1, -1, 1, -1_565), Term(1, 0, 0, 1, -1_491), Term(0, 1, 1, 1, -1_475),
        Term(0, 1, 1, -1, -1_410), Term(0, 1, 0, -1, -1_344), Term(1, 0, 0, -1, -1_335),
        Term(0, 0, 3, 1, 1_107), Term(4, 0, 0, -1, 1_021), Term(4, 0, -1, 1, 833),
        Term(0, 0, 1, -3, 777), Term(4, 0, -2, 1, 671), Term(2, 0, 0, -3, 607),
        Term(2, 0, 2, -1, 596), Term(2, -1, 1, -1, 491), Term(2, 0, -2, 1, -451),
        Term(0, 0, 3, -1, 439), Term(2, 0, 2, 1, 422), Term(2, 0, -3, -1, 421),
        Term(2, 1, -1, 1, -366), Term(2, 1, 0, 1, -351), Term(4, 0, 0, 1, 331),
        Term(2, -1, 1, 1, 315), Term(2, -2, 0, -1, 302), Term(0, 0, 1, 3, -283),
        Term(2, 1, 1, -1, -229), Term(1, 1, 0, -1, 223), Term(1, 1, 0, 1, 223),
        Term(0, 1, -2, -1, -220), Term(2, 1, -1, -1, -220), Term(1, 0, 1, 1, -185),
        Term(2, -1, -2, -1, 181), Term(0, 1, 2, 1, -177), Term(4, 0, -2, -1, 176),
        Term(4, -1, -1, -1, 166), Term(1, 0, 1, -1, -164), Term(4, 0, 1, -1, 132),
        Term(1, 0, -1, -1, -119), Term(4, -1, 0, -1, 115), Term(2, -2, 0, 1, 107),
    ]
}
