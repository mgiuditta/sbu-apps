import Foundation
import Testing
@testable import SbuLevel

struct LevelReadingAxesTests {
    @Test func flatReadsEachAxisSigned() {
        let reading = LevelReading(gravity: Gravity(x: sin(.pi / 60), y: -sin(.pi / 90), z: -0.998), calibration: .none)

        #expect(abs(reading.tiltX - 3) < 1e-9)
        #expect(abs(reading.tiltY + 2) < 1e-9)
    }

    @Test func anEdgeHasNoAxes() {
        let reading = LevelReading(gravity: .standing(rotatedBy: 20), calibration: .none)

        #expect(reading.tiltX == 0)
        #expect(reading.tiltY == 0)
    }
}
