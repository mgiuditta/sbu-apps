import Foundation
import Testing
@testable import SbuClean

struct BestShotTests {
    nonisolated struct Case: CustomTestStringConvertible, Sendable {
        let name: String
        let candidates: [ShotCandidate]
        let best: String

        var testDescription: String { name }
    }

    nonisolated static let cases: [Case] = [
        Case(name: "favourite beats sharper", candidates: [
            ShotCandidate(id: "sharp", sharpness: 900),
            ShotCandidate(id: "favourite", isFavorite: true, sharpness: 100),
        ], best: "favourite"),
        Case(name: "edited beats better face", candidates: [
            ShotCandidate(id: "face", faceQuality: 0.9),
            ShotCandidate(id: "edited", hasAdjustments: true, faceQuality: 0.4),
        ], best: "edited"),
        Case(name: "better face beats sharper", candidates: [
            ShotCandidate(id: "blink", faceQuality: 0.3, sharpness: 900),
            ShotCandidate(id: "smile", faceQuality: 0.8, sharpness: 500),
        ], best: "smile"),
        Case(name: "close face scores fall to sharpness", candidates: [
            ShotCandidate(id: "soft", faceQuality: 0.62, sharpness: 300),
            ShotCandidate(id: "crisp", faceQuality: 0.6, sharpness: 600),
        ], best: "crisp"),
        Case(name: "clearly sharper wins", candidates: [
            ShotCandidate(id: "blurry", sharpness: 120),
            ShotCandidate(id: "sharp", sharpness: 480),
            ShotCandidate(id: "middle", sharpness: 300),
        ], best: "sharp"),
        Case(name: "same sharpness, more pixels", candidates: [
            ShotCandidate(id: "small", sharpness: 400, pixelCount: 3_000_000),
            ShotCandidate(id: "large", sharpness: 410, pixelCount: 12_000_000),
        ], best: "large"),
        Case(name: "all equal, the oldest is the original", candidates: [
            ShotCandidate(id: "copy", sharpness: 400, pixelCount: 100, date: Fixture.date(5, 2)),
            ShotCandidate(id: "original", sharpness: 400, pixelCount: 100, date: Fixture.date(5, 1)),
        ], best: "original"),
    ]

    @Test(arguments: cases)
    func picksTheBestShot(_ testCase: Case) {
        #expect(BestShot.best(of: testCase.candidates) == testCase.best)
    }

    @Test func orderPutsTheBestFirstAndKeepsTheOthers() {
        let ordered = BestShot.ordered([
            ShotCandidate(id: "a", sharpness: 100),
            ShotCandidate(id: "b", sharpness: 500),
            ShotCandidate(id: "c", sharpness: 110),
        ])
        #expect(ordered == ["b", "a", "c"])
    }

    @Test func emptyGroupHasNoBest() {
        #expect(BestShot.best(of: []) == nil)
    }
}
