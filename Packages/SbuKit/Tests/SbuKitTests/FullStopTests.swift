import SwiftUI
import Testing
@testable import SbuKit

/// The full stop takes its side and gap from `mark-size` and `mark-gap`.
struct FullStopTests {
    @Test(arguments: [40.0, 64.0, 100.0])
    func sizeFollowsTheFigure(fontSize: Double) throws {
        let size = CGFloat(fontSize)
        let renderer = ImageRenderer(content: SbuFullStop(fontSize: size).fixedSize())
        renderer.scale = 1
        let image = try #require(renderer.uiImage)

        let side = size * SbuTheme.markSize
        #expect(abs(image.size.width - (side + size * SbuTheme.markGap)) <= 1)
        #expect(abs(image.size.height - side) <= 1)
    }
}
