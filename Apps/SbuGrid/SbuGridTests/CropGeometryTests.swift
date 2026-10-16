import CoreGraphics
import Testing
@testable import SbuGrid

struct CropGeometryTests {
    let portrait = CGSize(width: 1200, height: 1600)

    private func isClose(_ a: CGRect, _ b: CGRect, tolerance: CGFloat = 1e-9) -> Bool {
        abs(a.minX - b.minX) < tolerance && abs(a.minY - b.minY) < tolerance
            && abs(a.width - b.width) < tolerance && abs(a.height - b.height) < tolerance
    }

    private func pixelAspect(_ rect: CGRect, _ size: CGSize) -> Double {
        Double(rect.width * size.width / (rect.height * size.height))
    }

    private func isInside(_ rect: CGRect) -> Bool {
        rect.minX >= -1e-9 && rect.minY >= -1e-9 && rect.maxX <= 1 + 1e-9 && rect.maxY <= 1 + 1e-9
    }

    @Test func noSheetCropsNothing() {
        #expect(CropGeometry.fitted(aspect: nil, imageSize: portrait) == CropGeometry.whole)
    }

    @Test(arguments: [
        // A4 portrait (0.707) on a 3:4 photo (0.75): full height, narrower.
        (21.0 / 29.7, CGSize(width: 1200, height: 1600)),
        // A4 landscape on the same photo: full width, shorter.
        (29.7 / 21.0, CGSize(width: 1200, height: 1600)),
        // A square on a panorama.
        (1.0, CGSize(width: 4000, height: 1000)),
        // The photo's own shape: the whole photo.
        (0.75, CGSize(width: 1200, height: 1600)),
        (0.01, CGSize(width: 1200, height: 1600)),
        (100.0, CGSize(width: 1200, height: 1600)),
    ])
    func fitsTheLargestCentredCropOfTheSheet(aspect: Double, size: CGSize) {
        let rect = CropGeometry.fitted(aspect: aspect, imageSize: size)
        #expect(abs(pixelAspect(rect, size) - aspect) < 1e-9)
        #expect(isInside(rect))
        #expect(abs(rect.width - 1) < 1e-9 || abs(rect.height - 1) < 1e-9)
        #expect(abs(rect.midX - 0.5) < 1e-9)
        #expect(abs(rect.midY - 0.5) < 1e-9)
    }

    @Test(arguments: [0.0, -1.0, Double.nan, Double.infinity])
    func anAbsurdShapeCropsNothing(aspect: Double) {
        #expect(CropGeometry.fitted(aspect: aspect, imageSize: portrait) == CropGeometry.whole)
    }

    @Test func anAbsurdPhotoCropsNothing() {
        #expect(CropGeometry.fitted(aspect: 1, imageSize: .zero) == CropGeometry.whole)
    }

    @Test func movesInsideThePhoto() {
        let rect = CGRect(x: 0.2, y: 0.2, width: 0.5, height: 0.5)
        #expect(isClose(CropGeometry.moved(rect, by: CGSize(width: 0.1, height: -0.1)), CGRect(x: 0.3, y: 0.1, width: 0.5, height: 0.5)))
        #expect(isClose(CropGeometry.moved(rect, by: CGSize(width: 5, height: 5)), CGRect(x: 0.5, y: 0.5, width: 0.5, height: 0.5)))
        #expect(isClose(CropGeometry.moved(rect, by: CGSize(width: -5, height: -5)), CGRect(x: 0, y: 0, width: 0.5, height: 0.5)))
        #expect(CropGeometry.moved(rect, by: CGSize(width: CGFloat.nan, height: 0)) == rect)
    }

    @Test func theWholePhotoCannotMove() {
        #expect(CropGeometry.moved(CropGeometry.whole, by: CGSize(width: 0.3, height: 0.3)) == CropGeometry.whole)
    }

    @Test(arguments: CropCorner.allCases)
    func aFreeCornerFollowsTheFingerAndTheOppositeStays(corner: CropCorner) {
        let rect = CGRect(x: 0.25, y: 0.25, width: 0.5, height: 0.5)
        let target = CGPoint(x: corner.isLeft ? 0.1 : 0.9, y: corner.isTop ? 0.15 : 0.85)
        let dragged = CropGeometry.dragged(rect, corner: corner, to: target, aspect: nil, imageSize: portrait)
        let moved = corner.point(in: dragged)
        let still = corner.opposite.point(in: dragged)
        #expect(abs(moved.x - target.x) < 1e-9 && abs(moved.y - target.y) < 1e-9)
        let anchor = corner.opposite.point(in: rect)
        #expect(abs(still.x - anchor.x) < 1e-9 && abs(still.y - anchor.y) < 1e-9)
    }

    @Test(arguments: CropCorner.allCases)
    func aSheetCornerKeepsTheShape(corner: CropCorner) {
        let aspect = 21.0 / 29.7
        let rect = CropGeometry.fitted(aspect: aspect, imageSize: portrait)
        let small = CropGeometry.scaled(rect, by: 0.5, aspect: aspect, imageSize: portrait)
        for target in [CGPoint(x: 0.3, y: 0.9), CGPoint(x: 0, y: 0), CGPoint(x: 1, y: 1), CGPoint(x: 0.5, y: 0.5), CGPoint(x: 2, y: -3)] {
            let dragged = CropGeometry.dragged(small, corner: corner, to: target, aspect: aspect, imageSize: portrait)
            #expect(abs(pixelAspect(dragged, portrait) - aspect) < 1e-9)
            #expect(isInside(dragged))
            let anchor = corner.opposite.point(in: small)
            let still = corner.opposite.point(in: dragged)
            #expect(abs(still.x - anchor.x) < 1e-9 && abs(still.y - anchor.y) < 1e-9)
        }
    }

    @Test func draggingPastTheOppositeCornerStopsAtTheMinimum() {
        let rect = CGRect(x: 0.25, y: 0.25, width: 0.5, height: 0.5)
        let dragged = CropGeometry.dragged(rect, corner: .bottomRight, to: CGPoint(x: 0, y: 0), aspect: nil, imageSize: portrait)
        // A twentieth of the 1200-pixel side: 60 pixels.
        #expect(abs(dragged.width * portrait.width - 60) < 1e-9)
        #expect(abs(dragged.height * portrait.height - 60) < 1e-9)
        #expect(dragged.origin == rect.origin)
    }

    @Test func draggingOutsideThePhotoStopsAtItsEdge() {
        let rect = CGRect(x: 0.25, y: 0.25, width: 0.5, height: 0.5)
        let dragged = CropGeometry.dragged(rect, corner: .bottomRight, to: CGPoint(x: 7, y: 9), aspect: nil, imageSize: portrait)
        #expect(isClose(dragged, CGRect(x: 0.25, y: 0.25, width: 0.75, height: 0.75)))
    }

    @Test func anAbsurdDragChangesNothing() {
        let rect = CGRect(x: 0.25, y: 0.25, width: 0.5, height: 0.5)
        #expect(CropGeometry.dragged(rect, corner: .topLeft, to: CGPoint(x: CGFloat.nan, y: 0), aspect: nil, imageSize: portrait) == rect)
        #expect(CropGeometry.dragged(rect, corner: .topLeft, to: .zero, aspect: nil, imageSize: .zero) == rect)
    }

    @Test(arguments: [0.5, 0.9, 1.1, 2.0, 100.0, 0.0001])
    func scalingKeepsTheCentreTheShapeAndThePhoto(factor: CGFloat) {
        let aspect = 1.0
        let rect = CropGeometry.scaled(CropGeometry.fitted(aspect: aspect, imageSize: portrait), by: 0.5, aspect: aspect, imageSize: portrait)
        let scaled = CropGeometry.scaled(rect, by: factor, aspect: aspect, imageSize: portrait)
        #expect(abs(pixelAspect(scaled, portrait) - aspect) < 1e-9)
        #expect(isInside(scaled))
        #expect(scaled.width * portrait.width >= 60 - 1e-9)
    }

    @Test func growingNearAnEdgeSlidesBackInside() {
        let rect = CGRect(x: 0.6, y: 0.6, width: 0.4, height: 0.4)
        let grown = CropGeometry.scaled(rect, by: 1.5, aspect: nil, imageSize: portrait)
        #expect(isInside(grown))
        #expect(abs(grown.width - 0.6) < 1e-9)
    }

    @Test(arguments: [0.0, -1.0, CGFloat.nan])
    func anAbsurdScaleChangesNothing(factor: CGFloat) {
        let rect = CGRect(x: 0.2, y: 0.2, width: 0.5, height: 0.5)
        #expect(CropGeometry.scaled(rect, by: factor, aspect: nil, imageSize: portrait) == rect)
    }

    @Test func pixelsAreWholeAndInsideThePhoto() {
        let pixels = CropGeometry.pixelRect(CGRect(x: 0.1001, y: 0.2, width: 0.5, height: 0.3333), imageSize: portrait)
        #expect(pixels.minX == pixels.minX.rounded())
        #expect(pixels.width == pixels.width.rounded())
        #expect(CGRect(origin: .zero, size: portrait).contains(pixels))
    }

    @Test(arguments: [
        CGRect(x: 0, y: 0, width: 0, height: 0),
        CGRect(x: 0.5, y: 0.5, width: -0.2, height: 0.2),
        CGRect(x: 0.9, y: 0.9, width: 0.5, height: 0.5),
        CGRect(x: CGFloat.nan, y: 0, width: 0.5, height: 0.5),
        CGRect(x: 0, y: 0, width: CGFloat.infinity, height: 0.5),
    ])
    func aCropThatMakesNoSenseIsTheWholePhoto(rect: CGRect) {
        #expect(CropGeometry.sanitized(rect) == nil)
        #expect(CropGeometry.pixelRect(rect, imageSize: portrait) == CGRect(origin: .zero, size: portrait))
    }

    @Test func aTinyCropIsStillAPixel() {
        let pixels = CropGeometry.pixelRect(CGRect(x: 0.5, y: 0.5, width: 0.000001, height: 0.000001), imageSize: portrait)
        #expect(pixels.width >= 1)
        #expect(pixels.height >= 1)
    }

    @Test func aCropOnTheEdgeWithRoundingIsKept() throws {
        let rect = try #require(CropGeometry.sanitized(CGRect(x: 0, y: 0, width: 1.00001, height: 1)))
        #expect(rect == CropGeometry.whole)
    }

    @Test func cornersKnowTheirOpposites() {
        for corner in CropCorner.allCases {
            #expect(corner.opposite.opposite == corner)
            #expect(corner.opposite.isLeft != corner.isLeft)
            #expect(corner.opposite.isTop != corner.isTop)
        }
        let rect = CGRect(x: 1, y: 2, width: 3, height: 4)
        #expect(CropCorner.topLeft.point(in: rect) == CGPoint(x: 1, y: 2))
        #expect(CropCorner.bottomRight.point(in: rect) == CGPoint(x: 4, y: 6))
    }
}
