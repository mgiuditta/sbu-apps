import CoreGraphics
import SbuKit
import Testing
@testable import SbuHabits

/// Play and the owner's badge on a ring: smaller on a small ring, as on an iPhone SE's full page.
struct RingBadgeSizeTests {
    @Test(arguments: [
        (CGFloat(60), CGFloat(32)),
        (95, 32),
        (96, 44),
        (140, 44),
    ])
    func sideFollowsTheRing(ringSide: CGFloat, expected: CGFloat) {
        #expect(RingBadgeSize.side(forRingSide: ringSide) == expected)
    }

    @Test(arguments: [CGFloat(60), 96, 140])
    func badgeSitsOnTheStroke(ringSide: CGFloat) {
        let offset = RingBadgeSize.offset(inRingOfSide: ringSide)
        let distance = (offset * offset * 2).squareRoot()
        #expect(abs(distance - ringSide / 2) < 0.001)
    }

    @Test(arguments: [CGFloat(60), 96, 140])
    func badgeStaysAroundHalfTheRingAtMost(ringSide: CGFloat) {
        #expect(RingBadgeSize.side(forRingSide: ringSide) / ringSide < 0.55)
        #expect(RingBadgeSize.side(forRingSide: ringSide) <= SbuTheme.controlRoundSm)
    }
}
