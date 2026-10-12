import Foundation

/// The arguments of one phase in Meeus chapter 49, in degrees, and the periodic corrections
/// (in days) they give to its mean instant.
nonisolated struct PhaseArguments: Sendable {
    /// Eccentricity factor of the Earth's orbit.
    var e: Double
    /// Sun's mean anomaly.
    var m: Double
    /// Moon's mean anomaly.
    var mPrime: Double
    /// Moon's argument of latitude.
    var f: Double
    /// Longitude of the ascending node of the lunar orbit.
    var omega: Double

    private func sine(_ degrees: Double) -> Double { MoonAstronomy.sine(degrees) }
    private func cosine(_ degrees: Double) -> Double { MoonAstronomy.cosine(degrees) }

    var newMoonCorrection: Double {
        -0.40720 * sine(mPrime)
            + 0.17241 * e * sine(m)
            + syzygyTerms(first: 0.01608, second: 0.01039, third: 0.00739, fourth: -0.00514, fifth: 0.00208)
    }

    var fullMoonCorrection: Double {
        -0.40614 * sine(mPrime)
            + 0.17302 * e * sine(m)
            + syzygyTerms(first: 0.01614, second: 0.01043, third: 0.00734, fourth: -0.00515, fifth: 0.00209)
    }

    /// The terms new and full moon share; the first five differ slightly between them.
    private func syzygyTerms(first: Double, second: Double, third: Double, fourth: Double, fifth: Double) -> Double {
        var sum = first * sine(2 * mPrime)
        sum += second * sine(2 * f)
        sum += third * e * sine(mPrime - m)
        sum += fourth * e * sine(mPrime + m)
        sum += fifth * e * e * sine(2 * m)
        sum += -0.00111 * sine(mPrime - 2 * f)
        sum += -0.00057 * sine(mPrime + 2 * f)
        sum += 0.00056 * e * sine(2 * mPrime + m)
        sum += -0.00042 * sine(3 * mPrime)
        sum += 0.00042 * e * sine(m + 2 * f)
        sum += 0.00038 * e * sine(m - 2 * f)
        sum += -0.00024 * e * sine(2 * mPrime - m)
        sum += -0.00017 * sine(omega)
        sum += -0.00007 * sine(mPrime + 2 * m)
        sum += 0.00004 * sine(2 * mPrime - 2 * f)
        sum += 0.00004 * sine(3 * m)
        sum += 0.00003 * sine(mPrime + m - 2 * f)
        sum += 0.00003 * sine(2 * mPrime + 2 * f)
        sum += -0.00003 * sine(mPrime + m + 2 * f)
        sum += 0.00003 * sine(mPrime - m + 2 * f)
        sum += -0.00002 * sine(mPrime - m - 2 * f)
        sum += -0.00002 * sine(3 * mPrime + m)
        sum += 0.00002 * sine(4 * mPrime)
        return sum
    }

    var quarterCorrection: Double {
        var sum = -0.62801 * sine(mPrime)
        sum += 0.17172 * e * sine(m)
        sum += -0.01183 * e * sine(mPrime + m)
        sum += 0.00862 * sine(2 * mPrime)
        sum += 0.00804 * sine(2 * f)
        sum += 0.00454 * e * sine(mPrime - m)
        sum += 0.00204 * e * e * sine(2 * m)
        sum += -0.00180 * sine(mPrime - 2 * f)
        sum += -0.00070 * sine(mPrime + 2 * f)
        sum += -0.00040 * sine(3 * mPrime)
        sum += -0.00034 * e * sine(2 * mPrime - m)
        sum += 0.00032 * e * sine(m + 2 * f)
        sum += 0.00032 * e * sine(m - 2 * f)
        sum += -0.00028 * e * e * sine(mPrime + 2 * m)
        sum += 0.00027 * e * sine(2 * mPrime + m)
        sum += -0.00017 * sine(omega)
        sum += -0.00005 * sine(mPrime - m - 2 * f)
        sum += 0.00004 * sine(2 * mPrime + 2 * f)
        sum += -0.00004 * sine(mPrime + m + 2 * f)
        sum += 0.00004 * sine(mPrime - 2 * m)
        sum += 0.00003 * sine(mPrime + m - 2 * f)
        sum += 0.00003 * sine(3 * m)
        sum += 0.00002 * sine(2 * mPrime - 2 * f)
        sum += 0.00002 * sine(mPrime - m + 2 * f)
        sum += -0.00002 * sine(3 * mPrime + m)
        return sum
    }

    /// Added to the first quarter, subtracted from the last.
    var quarterW: Double {
        0.00306
            - 0.00038 * e * cosine(m)
            + 0.00026 * cosine(mPrime)
            - 0.00002 * cosine(mPrime - m)
            + 0.00002 * cosine(mPrime + m)
            + 0.00002 * cosine(2 * f)
    }
}
