import SwiftUI
import Testing
@testable import SbuSpeed

struct DialArcTests {
    @Test(arguments: [CGRect(x: 0, y: 0, width: 240, height: 180), CGRect(x: 10, y: 20, width: 400, height: 300)])
    func fullArcFillsItsBox(rect: CGRect) {
        let bounds = DialArc().path(in: rect).boundingRect

        #expect(abs(bounds.minX - rect.minX) < 0.5)
        #expect(abs(bounds.maxX - rect.maxX) < 0.5)
        #expect(abs(bounds.minY - rect.minY) < 0.5)
        #expect(abs(bounds.maxY - rect.maxY) < 0.5)
    }

    @Test func emptyArcDrawsNothingVisible() {
        let bounds = DialArc(fraction: 0).path(in: CGRect(x: 0, y: 0, width: 240, height: 180)).boundingRect

        #expect(bounds.width < 0.5)
        #expect(bounds.height < 0.5)
    }

    @Test func halfArcEndsAtTheTop() {
        // Half of 240° from 150° is 270°: straight up.
        let bounds = DialArc(fraction: 0.5).path(in: CGRect(x: 0, y: 0, width: 240, height: 180)).boundingRect

        #expect(abs(bounds.maxX - 120) < 0.5)
        #expect(abs(bounds.minY) < 0.5)
    }
}
