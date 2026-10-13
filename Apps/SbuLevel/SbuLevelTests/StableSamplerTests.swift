import Testing
@testable import SbuLevel

struct StableSamplerTests {
    @Test func aSecondOfSteadySamplesGivesTheirMean() {
        var sampler = StableSampler()
        var outcome = StableSampler.Outcome.collecting(progress: 0)

        for index in 0..<StableSampler.sampleCount {
            // Sensor noise well inside the tolerance.
            let noise = index.isMultiple(of: 2) ? 0.1 : -0.1
            outcome = sampler.add(.standing(rotatedBy: 10 + noise))
        }

        guard case .stable(let mean) = outcome else {
            Issue.record("Expected a stable reading, got \(outcome)")
            return
        }
        #expect(abs(mean.rotation - 10) < 0.01)
    }

    @Test func progressGrowsWithEachSample() {
        var sampler = StableSampler()

        _ = sampler.add(.standing(rotatedBy: 0))
        let outcome = sampler.add(.standing(rotatedBy: 0))

        #expect(outcome == .collecting(progress: 2 / Double(StableSampler.sampleCount)))
    }

    @Test func aJoltStartsOver() {
        var sampler = StableSampler()
        for _ in 0..<10 {
            _ = sampler.add(.standing(rotatedBy: 0))
        }

        #expect(sampler.add(.standing(rotatedBy: 1)) == .moved)
        #expect(sampler.samples.count == 1)
    }
}
