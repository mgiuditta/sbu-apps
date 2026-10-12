import CoreGraphics
import Foundation
import Testing
@testable import SbuMoon

struct MoonDiscTests {
    private let center = CGPoint(x: 100, y: 100)
    private let radius: CGFloat = 50

    /// Area of a polygon by the shoelace formula, as a fraction of the whole disc.
    private func litFraction(of disc: MoonDisc) -> Double {
        let points = disc.litOutline(center: center, radius: radius, segments: 720)
        let doubledArea = zip(points, points.dropFirst() + points.prefix(1)).reduce(0.0) { sum, pair in
            sum + Double(pair.0.x * pair.1.y - pair.1.x * pair.0.y)
        }
        return abs(doubledArea) / 2 / (Double.pi * Double(radius * radius))
    }

    @Test(arguments: [0.0, 0.1, 0.25, 0.5, 0.6786, 0.9, 1.0], [true, false])
    func litAreaIsTheIlluminatedFraction(illumination: Double, isWaxing: Bool) {
        let disc = MoonDisc(illumination: illumination, isWaxing: isWaxing)

        #expect(abs(litFraction(of: disc) - illumination) < 0.001)
    }

    @Test(arguments: [0.1, 0.5, 0.9])
    func waxingIsLitOnTheRightAndWaningOnTheLeft(illumination: Double) {
        let waxing = MoonDisc(illumination: illumination, isWaxing: true).litOutline(center: center, radius: radius)
        let waning = MoonDisc(illumination: illumination, isWaxing: false).litOutline(center: center, radius: radius)

        #expect(waxing.map(\.x).max() == center.x + radius)
        #expect(waning.map(\.x).min() == center.x - radius)
        #expect(zip(waxing, waning).allSatisfy { abs(($0.x - center.x) + ($1.x - center.x)) < 0.000_1 && $0.y == $1.y })
    }

    @Test func terminatorIsStraightAtTheQuartersAndTheLimbAtFullMoon() {
        #expect(MoonDisc(illumination: 0.5, isWaxing: true).terminatorSemiAxis == 0)
        #expect(MoonDisc(illumination: 0, isWaxing: true).terminatorSemiAxis == 1)
        #expect(MoonDisc(illumination: 1, isWaxing: true).terminatorSemiAxis == -1)
        #expect(MoonDisc(illumination: 0.25, isWaxing: false).terminatorSemiAxis == -0.5)
    }

    @Test func illuminationIsClamped() {
        #expect(MoonDisc(illumination: 1.2, isWaxing: true).illumination == 1)
        #expect(MoonDisc(illumination: -0.1, isWaxing: true).illumination == 0)
    }

    @Test func outlineStaysOnTheDisc() {
        let points = MoonDisc(illumination: 0.3, isWaxing: true).litOutline(center: center, radius: radius)

        #expect(points.allSatisfy { hypot($0.x - center.x, $0.y - center.y) <= radius + 0.000_1 })
    }
}
