/// How sharp a picture is: the variance of its Laplacian, the classic focus measure.
///
/// A blurred copy of a picture always scores lower than the sharp one, which is all the best
/// shot needs: the number is only compared inside a group.
nonisolated enum Sharpness {
    /// The variance of the 4-neighbour Laplacian of a grey picture.
    /// - Parameters:
    ///   - pixels: Grey levels, row by row.
    ///   - width: Pixels per row.
    ///   - height: Rows.
    static func laplacianVariance(of pixels: [UInt8], width: Int, height: Int) -> Float {
        guard width > 2, height > 2, pixels.count >= width * height else { return 0 }

        var sum: Double = 0
        var sumOfSquares: Double = 0
        for y in 1..<(height - 1) {
            for x in 1..<(width - 1) {
                let center = y * width + x
                let laplacian = Double(pixels[center - width]) + Double(pixels[center + width])
                    + Double(pixels[center - 1]) + Double(pixels[center + 1])
                    - 4 * Double(pixels[center])
                sum += laplacian
                sumOfSquares += laplacian * laplacian
            }
        }
        let count = Double((width - 2) * (height - 2))
        let mean = sum / count
        return Float(sumOfSquares / count - mean * mean)
    }
}
