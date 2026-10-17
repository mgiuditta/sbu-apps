import Testing
@testable import SbuSpeed

struct GPSAccuracyTests {
    @Test(arguments: [
        (-1.0, GPSAccuracy.none),
        (0, .precise),
        (10, .precise),
        (10.1, .good),
        (30, .good),
        (31, .weak),
        (500, .weak),
    ])
    func horizontalAccuracyPicksTheWord(meters: Double, expected: GPSAccuracy) {
        #expect(GPSAccuracy(horizontalAccuracy: meters) == expected)
    }
}
