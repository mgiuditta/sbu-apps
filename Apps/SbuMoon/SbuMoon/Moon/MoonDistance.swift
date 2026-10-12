import Foundation

/// Distance between the centres of the Earth and the moon, from the periodic terms of Meeus
/// table 47.A (error of a few kilometres).
nonisolated enum MoonDistance {
    /// Mean distance, in kilometres.
    static let meanKilometres = 385_000.56

    /// One term of Σr: multiples of D, M, M′, F and the coefficient of the cosine, in metres.
    private struct Term {
        var d: Double
        var m: Double
        var mPrime: Double
        var f: Double
        var coefficient: Double
    }

    /// The distance at an instant, in kilometres.
    static func kilometres(at date: Date) -> Double {
        kilometres(arguments: LunarArguments(julianCenturies: MoonAstronomy.julianCenturies(at: date)))
    }

    /// The distance for given arguments, in kilometres (Meeus 47.A, Σr).
    static func kilometres(arguments a: LunarArguments) -> Double {
        let sum = terms.reduce(0.0) { sum, term in
            let angle = term.d * a.elongation + term.m * a.sunAnomaly + term.mPrime * a.moonAnomaly + term.f * a.latitude
            // Terms with M shrink with the eccentricity of the Earth's orbit, once per multiple.
            let eccentricity = pow(a.eccentricity, abs(term.m))
            return sum + term.coefficient * eccentricity * MoonAstronomy.cosine(angle)
        }
        return meanKilometres + sum / 1000
    }

    /// The terms of table 47.A whose Σr coefficient is not zero.
    private static let terms: [Term] = [
        Term(d: 0, m: 0, mPrime: 1, f: 0, coefficient: -20_905_355),
        Term(d: 2, m: 0, mPrime: -1, f: 0, coefficient: -3_699_111),
        Term(d: 2, m: 0, mPrime: 0, f: 0, coefficient: -2_955_968),
        Term(d: 0, m: 0, mPrime: 2, f: 0, coefficient: -569_925),
        Term(d: 0, m: 1, mPrime: 0, f: 0, coefficient: 48_888),
        Term(d: 0, m: 0, mPrime: 0, f: 2, coefficient: -3_149),
        Term(d: 2, m: 0, mPrime: -2, f: 0, coefficient: 246_158),
        Term(d: 2, m: -1, mPrime: -1, f: 0, coefficient: -152_138),
        Term(d: 2, m: 0, mPrime: 1, f: 0, coefficient: -170_733),
        Term(d: 2, m: -1, mPrime: 0, f: 0, coefficient: -204_586),
        Term(d: 0, m: 1, mPrime: -1, f: 0, coefficient: -129_620),
        Term(d: 1, m: 0, mPrime: 0, f: 0, coefficient: 108_743),
        Term(d: 0, m: 1, mPrime: 1, f: 0, coefficient: 104_755),
        Term(d: 2, m: 0, mPrime: 0, f: -2, coefficient: 10_321),
        Term(d: 0, m: 0, mPrime: 1, f: -2, coefficient: 79_661),
        Term(d: 4, m: 0, mPrime: -1, f: 0, coefficient: -34_782),
        Term(d: 0, m: 0, mPrime: 3, f: 0, coefficient: -23_210),
        Term(d: 4, m: 0, mPrime: -2, f: 0, coefficient: -21_636),
        Term(d: 2, m: 1, mPrime: -1, f: 0, coefficient: 24_208),
        Term(d: 2, m: 1, mPrime: 0, f: 0, coefficient: 30_824),
        Term(d: 1, m: 0, mPrime: -1, f: 0, coefficient: -8_379),
        Term(d: 1, m: 1, mPrime: 0, f: 0, coefficient: -16_675),
        Term(d: 2, m: -1, mPrime: 1, f: 0, coefficient: -12_831),
        Term(d: 2, m: 0, mPrime: 2, f: 0, coefficient: -10_445),
        Term(d: 4, m: 0, mPrime: 0, f: 0, coefficient: -11_650),
        Term(d: 2, m: 0, mPrime: -3, f: 0, coefficient: 14_403),
        Term(d: 0, m: 1, mPrime: -2, f: 0, coefficient: -7_003),
        Term(d: 2, m: -1, mPrime: -2, f: 0, coefficient: 10_056),
        Term(d: 1, m: 0, mPrime: 1, f: 0, coefficient: 6_322),
        Term(d: 2, m: -2, mPrime: 0, f: 0, coefficient: -9_884),
        Term(d: 0, m: 1, mPrime: 2, f: 0, coefficient: 5_751),
        Term(d: 2, m: -2, mPrime: -1, f: 0, coefficient: -4_950),
        Term(d: 2, m: 0, mPrime: 1, f: -2, coefficient: 4_130),
        Term(d: 4, m: -1, mPrime: -1, f: 0, coefficient: -3_958),
        Term(d: 3, m: 0, mPrime: -1, f: 0, coefficient: 3_258),
        Term(d: 2, m: 1, mPrime: 1, f: 0, coefficient: 2_616),
        Term(d: 4, m: -1, mPrime: -2, f: 0, coefficient: -1_897),
        Term(d: 0, m: 2, mPrime: -1, f: 0, coefficient: -2_117),
        Term(d: 2, m: 2, mPrime: -1, f: 0, coefficient: 2_354),
        Term(d: 4, m: 0, mPrime: 1, f: 0, coefficient: -1_423),
        Term(d: 0, m: 0, mPrime: 4, f: 0, coefficient: -1_117),
        Term(d: 4, m: -1, mPrime: 0, f: 0, coefficient: -1_571),
        Term(d: 1, m: 0, mPrime: -2, f: 0, coefficient: -1_739),
        Term(d: 0, m: 0, mPrime: 2, f: -2, coefficient: -4_421),
        Term(d: 0, m: 2, mPrime: 1, f: 0, coefficient: 1_165),
        Term(d: 2, m: 0, mPrime: -1, f: -2, coefficient: 8_752),
    ]
}
