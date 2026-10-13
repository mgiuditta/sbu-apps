import Testing
@testable import SbuNoise

struct VolumeRampTests {
    private let fadeOut = VolumeRamp(from: 1, to: 0, duration: .seconds(30))

    @Test(arguments: [
        (Duration.seconds(-1), Float(1)),
        (.zero, 1),
        (.seconds(15), 0.5),
        (.seconds(30), 0),
        (.seconds(90), 0),
    ])
    func volumeFollowsTheRampAndStaysAtItsEnds(_ elapsed: Duration, expected: Float) {
        #expect(fadeOut.volume(after: elapsed) == expected)
    }

    @Test func zeroDurationJumpsToTheTarget() {
        #expect(VolumeRamp(from: 0, to: 0.8, duration: .zero).volume(after: .zero) == 0.8)
    }
}
