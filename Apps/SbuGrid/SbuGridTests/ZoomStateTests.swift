import CoreGraphics
import Testing
@testable import SbuGrid

struct ZoomStateTests {
    let size = CGSize(width: 300, height: 400)

    @Test func startsWhole() {
        #expect(ZoomState.identity.scale == 1)
        #expect(ZoomState.identity.offset == .zero)
        #expect(ZoomState.identity.isZoomed == false)
    }

    @Test(arguments: [(2.0, 2.0), (0.5, 1.0), (0.0001, 1.0), (100.0, 8.0), (8.0, 8.0)])
    func zoomStaysBetweenWholeAndEightTimes(factor: CGFloat, expected: CGFloat) {
        #expect(ZoomState.identity.zoomed(by: factor, in: size).scale == expected)
    }

    @Test(arguments: [0, -2, CGFloat.nan, CGFloat.infinity, -CGFloat.infinity])
    func anAbsurdFactorChangesNothing(factor: CGFloat) {
        let zoomed = ZoomState.identity.zoomed(by: 2, in: size)
        #expect(zoomed.zoomed(by: factor, in: size) == zoomed)
    }

    @Test func theWholePhotoCannotMove() {
        #expect(ZoomState.identity.panned(by: CGSize(width: 80, height: -40), in: size).offset == .zero)
    }

    @Test func aZoomedPhotoMovesUpToItsEdges() {
        let zoomed = ZoomState.identity.zoomed(by: 2, in: size)
        // Twice as big: 150 points spare on each side across, 200 down.
        #expect(zoomed.maximumOffset(in: size) == CGSize(width: 150, height: 200))
        #expect(zoomed.panned(by: CGSize(width: 100, height: -50), in: size).offset == CGSize(width: 100, height: -50))
        #expect(zoomed.panned(by: CGSize(width: 1_000, height: -1_000), in: size).offset == CGSize(width: 150, height: -200))
    }

    @Test func zoomingOutPullsThePhotoBackInside() {
        let moved = ZoomState.identity.zoomed(by: 4, in: size).panned(by: CGSize(width: 450, height: 600), in: size)
        #expect(moved.offset == CGSize(width: 450, height: 600))
        let out = moved.zoomed(by: 0.5, in: size)
        #expect(out.scale == 2)
        // The offset halves with the zoom, so the same point stays in the middle, then fits.
        #expect(out.offset == CGSize(width: 150, height: 200))
        #expect(out.zoomed(by: 0.1, in: size) == .identity)
    }

    @Test func zoomingKeepsTheCentreStill() {
        let moved = ZoomState.identity.zoomed(by: 2, in: size).panned(by: CGSize(width: 60, height: 40), in: size)
        let further = moved.zoomed(by: 2, in: size)
        #expect(further.offset == CGSize(width: 120, height: 80))
    }

    @Test(arguments: [CGFloat.nan, CGFloat.infinity])
    func anAbsurdDragChangesNothing(value: CGFloat) {
        let zoomed = ZoomState.identity.zoomed(by: 2, in: size)
        #expect(zoomed.panned(by: CGSize(width: value, height: 10), in: size) == zoomed)
    }

    @Test(arguments: [CGSize.zero, CGSize(width: -10, height: 10), CGSize(width: CGFloat.nan, height: 10)])
    func anAbsurdViewKeepsThePhotoCentred(view: CGSize) {
        let zoomed = ZoomState.identity.zoomed(by: 3, in: view).panned(by: CGSize(width: 50, height: 50), in: view)
        #expect(zoomed.offset == .zero)
        #expect(zoomed.scale == 3)
    }

    @Test func aStepDoublesTheZoom() {
        #expect(ZoomState.step == 2)
        var zoom = ZoomState.identity
        for expected: CGFloat in [2, 4, 8, 8] {
            zoom = zoom.zoomed(by: ZoomState.step, in: size)
            #expect(zoom.scale == expected)
        }
    }
}
