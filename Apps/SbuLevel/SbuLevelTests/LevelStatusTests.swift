import Testing
@testable import SbuLevel

struct LevelStatusTests {
    private func readout(_ rotation: Double, reference: Double? = nil) -> Readout {
        Readout(
            reading: LevelReading(gravity: .standing(rotatedBy: rotation), calibration: .none),
            unit: .degrees,
            reference: reference.map { LevelReading(gravity: .standing(rotatedBy: $0), calibration: .none) }
        )
    }

    @Test(arguments: [
        (12.0, Double?.none, false, LevelStatus.edge),
        (0, nil, false, .level),
        (12, nil, true, .locked(isRelative: false)),
        (12, 10, true, .locked(isRelative: true)),
        (12, 10, false, .relative(atZero: false)),
        (12, 12, false, .relative(atZero: true)),
    ])
    func theLockComesFirstThenTheReference(rotation: Double, reference: Double?, isLocked: Bool, expected: LevelStatus) {
        #expect(LevelStatus(readout: readout(rotation, reference: reference), isLocked: isLocked) == expected)
    }

    @Test func flatOffLevelSaysInPiano() {
        let readout = Readout(reading: LevelReading(gravity: .lying(tiltedBy: 3), calibration: .none), unit: .degrees)

        #expect(LevelStatus(readout: readout, isLocked: false) == .flat)
    }

    @Test func theCameraMattersOnlyInSight() {
        #expect(LevelStatus(readout: readout(12), isLocked: false, camera: .unavailable) == .edge)
    }
}
