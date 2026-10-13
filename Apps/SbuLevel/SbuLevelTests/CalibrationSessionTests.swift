import Foundation
import Testing
@testable import SbuLevel

struct CalibrationSessionTests {
    private func feed(_ session: inout CalibrationSession, _ gravity: Gravity, times: Int = StableSampler.sampleCount, base: Calibration = .none) {
        let target = LevelReading(gravity: gravity, calibration: base).calibrationTarget
        for _ in 0..<times {
            session.add(gravity, on: target, base: base)
        }
    }

    @Test func samplesAreIgnoredUntilMisuraIsTapped() {
        var session = CalibrationSession()

        feed(&session, .standing(rotatedBy: 2))

        #expect(session.step == .first)
        #expect(session.isCapturing == false)
    }

    @Test func twoSteadyReadingsCalibrateTheSide() throws {
        var session = CalibrationSession()

        session.startCapture()
        feed(&session, .standing(rotatedBy: 3), times: StableSampler.sampleCount - 1)
        #expect(session.isCapturing)
        #expect(session.progress > 0.9)
        feed(&session, .standing(rotatedBy: 3), times: 1)
        #expect(session.step == .second)
        #expect(session.target == .edge(.bottom))
        #expect(session.isCapturing == false)

        session.startCapture()
        feed(&session, .standing(rotatedBy: -1))

        #expect(session.step == .done)
        let result = try #require(session.result)
        #expect(abs(result.bottom - 1) < 1e-9)
    }

    @Test func movingStartsTheCaptureOver() {
        var session = CalibrationSession()
        session.startCapture()

        feed(&session, .standing(rotatedBy: 3), times: 20)
        feed(&session, .standing(rotatedBy: 4), times: 1)

        #expect(session.notice == .moved)
        #expect(session.progress == 0)
        #expect(session.step == .first)

        feed(&session, .standing(rotatedBy: 4), times: StableSampler.sampleCount)
        #expect(session.step == .second)
        #expect(session.notice == nil)
    }

    @Test func theSecondReadingMustBeOnTheSameSide() {
        var session = CalibrationSession()
        session.startCapture()
        feed(&session, .standing(rotatedBy: 1))

        session.startCapture()
        feed(&session, .standing(rotatedBy: 90))

        #expect(session.notice == .wrongSide)
        #expect(session.step == .second)
        #expect(session.isCapturing)

        feed(&session, .standing(rotatedBy: -1))
        #expect(session.step == .done)
        #expect(session.notice == nil)
    }

    @Test func calibratesTheBubbleWhenLyingFlat() throws {
        var session = CalibrationSession()
        session.startCapture()
        feed(&session, Gravity(x: 0.03, y: 0.01, z: -1))
        session.startCapture()
        feed(&session, Gravity(x: -0.01, y: 0.01, z: -1))

        #expect(session.target == .flat)
        let result = try #require(session.result)
        #expect(abs(result.flatX - 0.01) < 1e-12)
        #expect(abs(result.flatY - 0.01) < 1e-12)
    }

    @Test func anImplausibleResultIsNotSavedAndStartsOver() {
        var session = CalibrationSession()
        session.startCapture()
        feed(&session, .standing(rotatedBy: 6))
        session.startCapture()
        // 6° then 4°: a 5° sensor error, more than any real sensor has.
        feed(&session, .standing(rotatedBy: 4))

        #expect(session.result == nil)
        #expect(session.notice == .implausible)
        #expect(session.step == .first)
        #expect(session.target == nil)

        session.startCapture()
        #expect(session.notice == nil)
    }
}
