import Testing
@testable import SbuLevel

struct DialGeometryTests {
    @Test(arguments: [(0.0, 0.0), (45, 45), (90, 90), (135, 45), (180, 0), (225, 45), (270, 90), (315, 45), (-30, 30)])
    func theDialReadsFrom0To90InEachQuarter(position: Double, value: Double) {
        #expect(DialGeometry.value(at: position) == value)
    }

    @Test(arguments: [(0.0, 90.0), (90, 0), (45, 45), (180, 90), (-90, 0), (30, 60)])
    func aTurnedDialReads0AtTheSides(position: Double, value: Double) {
        #expect(DialGeometry.value(at: position, dialTurn: 90) == value)
    }

    @Test(arguments: [
        (0.0, 30.0, 0.0), (0, 50, 90), (0, -60, 90), (0, 170, 0), (0, 250, 90), (90, 90, 0), (90, 10, 90),
    ])
    func aDragSnapsToAQuarterAndOddQuartersSwapTheDial(turn: Double, degrees: Double, expected: Double) {
        #expect(DialGeometry.turn(turn, draggedBy: degrees) == expected)
    }

    @Test(arguments: [(370.0, 10.0), (-190, 170), (180, -180), (-180, -180), (540, -180)])
    func anglesFoldIntoOneTurn(degrees: Double, expected: Double) {
        #expect(Angles.normalized(degrees) == expected)
    }
}
