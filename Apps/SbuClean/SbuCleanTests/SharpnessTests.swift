import Testing
@testable import SbuClean

struct SharpnessTests {
    @Test func aFlatPictureHasNoSharpness() {
        let flat = [UInt8](repeating: 128, count: 16 * 16)
        #expect(Sharpness.laplacianVariance(of: flat, width: 16, height: 16) == 0)
    }

    @Test func hardEdgesAreSharperThanSoftOnes() {
        let side = 32
        let hard = (0..<(side * side)).map { index -> UInt8 in
            (index % side + index / side).isMultiple(of: 2) ? 0 : 255
        }
        let soft = (0..<(side * side)).map { index -> UInt8 in
            UInt8(index % side * 255 / (side - 1))
        }

        #expect(Sharpness.laplacianVariance(of: hard, width: side, height: side) > Sharpness.laplacianVariance(of: soft, width: side, height: side))
    }

    @Test(arguments: [(2, 10), (10, 2), (0, 0)])
    func tooSmallPicturesScoreZero(width: Int, height: Int) {
        let pixels = [UInt8](repeating: 9, count: width * height)
        #expect(Sharpness.laplacianVariance(of: pixels, width: width, height: height) == 0)
    }
}
