import Testing
@testable import SbuLevel

struct DialGeometryTests {
    @Test(arguments: [(0.0, 0.0), (45, 45), (90, 90), (135, 45), (180, 0), (225, 45), (270, 90), (315, 45), (-30, 30)])
    func theDialReadsFrom0To90InEachQuarter(position: Double, value: Double) {
        #expect(DialGeometry.value(at: position) == value)
    }

    @Test(arguments: [
        (30.0, 0.0, -30.0), (-30, 0, 30), (90, 0, -90), (150, 180, 30), (-150, 180, -30), (180, 180, 0),
    ])
    func theWedgeRunsFromTheNearest0ToTheNeedle(rotation: Double, start: Double, sweep: Double) {
        #expect(DialGeometry.wedgeStart(rotation: rotation) == start)
        #expect(abs(DialGeometry.wedgeSweep(rotation: rotation) - sweep) < 1e-9)
    }

    @Test(arguments: [-170.0, -95, -10, 0, 10, 95, 170])
    func theWedgeNeverSweepsMoreThanAQuarter(rotation: Double) {
        #expect(abs(DialGeometry.wedgeSweep(rotation: rotation)) <= 90)
    }

    @Test(arguments: [(370.0, 10.0), (-190, 170), (180, -180), (-180, -180), (540, -180)])
    func anglesFoldIntoOneTurn(degrees: Double, expected: Double) {
        #expect(Angles.normalized(degrees) == expected)
    }
}
