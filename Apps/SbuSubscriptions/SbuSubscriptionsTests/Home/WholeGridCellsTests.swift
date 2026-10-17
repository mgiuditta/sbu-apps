import CoreGraphics
import Testing
@testable import SbuSubscriptions

struct WholeGridCellsTests {
    @Test(arguments: [(0.0, 0.0), (1.0, 24.0), (24.0, 24.0), (59.33, 72.0), (72.0, 72.0)])
    func roundsUpToWholeCells(height: CGFloat, rounded: CGFloat) {
        #expect(WholeGridCells.rounded(height) == rounded)
    }
}
