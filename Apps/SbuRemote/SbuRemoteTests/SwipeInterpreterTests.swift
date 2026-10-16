import CoreGraphics
import Testing
@testable import SbuRemote

struct SwipeInterpreterTests {
    private func swipe(_ points: [CGPoint]) -> (keys: [RemoteKey], end: RemoteKey?) {
        var interpreter = SwipeInterpreter(stepDistance: 40, tapSlop: 10)
        var keys: [RemoteKey] = []
        for point in points { keys += interpreter.move(to: point) }
        return (keys, interpreter.end(at: points.last ?? .zero))
    }

    @Test(arguments: [
        (CGPoint(x: 150, y: 100), RemoteKey.right),
        (CGPoint(x: 50, y: 100), .left),
        (CGPoint(x: 100, y: 150), .down),
        (CGPoint(x: 100, y: 50), .up),
    ])
    func oneStepInTheDominantDirection(to end: CGPoint, key: RemoteKey) {
        let result = swipe([CGPoint(x: 100, y: 100), end])
        #expect(result.keys == [key])
        #expect(result.end == nil)
    }

    @Test func aLongSwipeRepeatsWhileTheFingerKeepsGoing() {
        let points = stride(from: 0, through: 130, by: 10).map { CGPoint(x: 0, y: CGFloat($0)) }
        #expect(swipe(points).keys == [.down, .down, .down])
    }

    @Test func aSlantedSwipeFollowsItsMainAxis() {
        #expect(swipe([CGPoint(x: 0, y: 0), CGPoint(x: 45, y: 20), CGPoint(x: 90, y: 35)]).keys == [.right, .right])
    }

    @Test func turningTheFingerChangesDirection() {
        let result = swipe([CGPoint(x: 0, y: 0), CGPoint(x: 45, y: 0), CGPoint(x: 45, y: 50)])
        #expect(result.keys == [.right, .down])
    }

    @Test func aTapIsOK() {
        #expect(swipe([CGPoint(x: 10, y: 10), CGPoint(x: 14, y: 13)]) == ([], .select))
    }

    @Test func aShortDragIsNeitherStepNorTap() {
        #expect(swipe([CGPoint(x: 10, y: 10), CGPoint(x: 35, y: 10)]) == ([], nil))
    }

    @Test func aSwipeThatComesBackIsNotATap() {
        let result = swipe([CGPoint(x: 0, y: 0), CGPoint(x: 50, y: 0), CGPoint(x: 2, y: 0)])
        #expect(result.keys == [.right])
        #expect(result.end == nil)
    }
}
