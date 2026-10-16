import CoreGraphics
import Testing
@testable import SbuGrid

struct AspectFitTests {
    @Test(arguments: [
        (CGSize(width: 1200, height: 1600), CGSize(width: 300, height: 600), CGSize(width: 300, height: 400)),
        (CGSize(width: 1600, height: 900), CGSize(width: 320, height: 500), CGSize(width: 320, height: 180)),
        (CGSize(width: 1, height: 1), CGSize(width: 300, height: 200), CGSize(width: 200, height: 200)),
        (CGSize(width: 10, height: 1000), CGSize(width: 300, height: 200), CGSize(width: 2, height: 200)),
        (CGSize(width: 300, height: 200), CGSize(width: 300, height: 200), CGSize(width: 300, height: 200)),
    ])
    func fitsTheShapeInTheBox(aspect: CGSize, container: CGSize, expected: CGSize) {
        let fitted = AspectFit.size(of: aspect, in: container)
        #expect(abs(fitted.width - expected.width) < 1e-9)
        #expect(abs(fitted.height - expected.height) < 1e-9)
        #expect(fitted.width <= container.width + 1e-9)
        #expect(fitted.height <= container.height + 1e-9)
    }

    @Test(arguments: [
        (CGSize.zero, CGSize(width: 300, height: 200)),
        (CGSize(width: 300, height: 200), CGSize.zero),
        (CGSize(width: -3, height: 2), CGSize(width: 300, height: 200)),
        (CGSize(width: CGFloat.nan, height: 2), CGSize(width: 300, height: 200)),
        (CGSize(width: 3, height: 2), CGSize(width: CGFloat.infinity, height: 200)),
    ])
    func absurdSizesFitToNothing(aspect: CGSize, container: CGSize) {
        #expect(AspectFit.size(of: aspect, in: container) == .zero)
    }
}
