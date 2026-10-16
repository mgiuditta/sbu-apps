import SwiftUI
import Testing
@testable import SbuKit

/// The full stop is a filled square of one of three sizes; one `.set` per screen.
struct FullStopTests {
    @Test(arguments: [(SbuFullStop.Size.hero, 24.0, 12.0), (.inline, 16, 8), (.mark, 10, 4)])
    func sizeIsACell(size: SbuFullStop.Size, side: Double, gap: Double) throws {
        let renderer = ImageRenderer(content: SbuFullStop(.set, size: size).fixedSize())
        renderer.scale = 1
        let image = try #require(renderer.uiImage)

        #expect(abs(image.size.width - (side + gap)) <= 1)
        #expect(abs(image.size.height - side) <= 1)
    }

    @Test func heroIsExactlyOneGridCell() {
        #expect(SbuFullStop.Size.hero.side == SbuTheme.gridCell)
    }

    @Test func setFullStopsAreCounted() {
        var count = SbuSetFullStopCount.defaultValue
        for next in [1, 0, 1] {
            SbuSetFullStopCount.reduce(value: &count) { next }
        }
        #expect(count == 2)
        #expect(!SbuSetFullStopCount.isAllowed(count))
        #expect(SbuSetFullStopCount.isAllowed(1))
        #expect(SbuSetFullStopCount.isAllowed(0))
    }
}
