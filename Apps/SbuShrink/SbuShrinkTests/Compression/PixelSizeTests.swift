import Testing
@testable import SbuShrink

struct PixelSizeTests {
    struct Case: Sendable, CustomTestStringConvertible {
        let width: Int
        let height: Int
        let percent: Int
        let expected: PixelSize
        var testDescription: String { "\(width)×\(height) at \(percent)%" }
    }

    @Test(arguments: [
        Case(width: 1920, height: 1080, percent: 80, expected: PixelSize(width: 1536, height: 864)),
        Case(width: 1080, height: 1920, percent: 50, expected: PixelSize(width: 540, height: 960)),
        Case(width: 3840, height: 2160, percent: 100, expected: PixelSize(width: 3840, height: 2160)),
        Case(width: 3840, height: 2160, percent: 10, expected: PixelSize(width: 384, height: 216)),
        // Odd sides round to even and never above the source.
        Case(width: 1081, height: 721, percent: 100, expected: PixelSize(width: 1080, height: 720)),
        Case(width: 1279, height: 719, percent: 50, expected: PixelSize(width: 640, height: 360)),
        // Never under 16 pixels.
        Case(width: 100, height: 100, percent: 10, expected: PixelSize(width: 16, height: 16)),
        // Unless the source is smaller.
        Case(width: 10, height: 10, percent: 50, expected: PixelSize(width: 10, height: 10)),
        Case(width: 3, height: 3, percent: 100, expected: PixelSize(width: 2, height: 2)),
        Case(width: 1, height: 1, percent: 100, expected: PixelSize(width: 2, height: 2)),
        // Absurd percentages are clamped to 1...100.
        Case(width: 1920, height: 1080, percent: 500, expected: PixelSize(width: 1920, height: 1080)),
        Case(width: 1920, height: 1080, percent: 0, expected: PixelSize(width: 20, height: 16)),
        Case(width: 1920, height: 1080, percent: -40, expected: PixelSize(width: 20, height: 16)),
        Case(width: 0, height: 0, percent: 80, expected: PixelSize(width: 0, height: 0)),
        Case(width: -10, height: 1080, percent: 80, expected: PixelSize(width: 0, height: 864)),
    ])
    func scaledSizeIsEvenAndBounded(_ testCase: Case) {
        let size = PixelSize(width: testCase.width, height: testCase.height).scaled(toPercent: testCase.percent)
        #expect(size == testCase.expected)
        #expect(size.width % 2 == 0)
        #expect(size.height % 2 == 0)
    }

    @Test(arguments: 1...100)
    func everyPercentStaysWithinTheSourceAndEven(percent: Int) {
        let source = PixelSize(width: 1919, height: 1081)
        let size = source.scaled(toPercent: percent)
        #expect(size.width <= source.width && size.height <= source.height)
        #expect(size.width % 2 == 0 && size.height % 2 == 0)
        #expect(size.width >= PixelSize.minimumSide && size.height >= PixelSize.minimumSide)
    }

    @Test func pixelCountMultipliesTheSides() {
        #expect(PixelSize(width: 1920, height: 1080).pixelCount == 2_073_600)
        #expect(PixelSize(width: 0, height: 1080).pixelCount == 0)
    }
}
