import Accelerate

/// Distances between Vision feature prints, the way `VNFeaturePrintObservation` measures them.
nonisolated enum FeatureDistance {
    /// The Euclidean distance between two prints of the same length.
    static func between(_ first: [Float], _ second: [Float]) -> Float {
        guard first.count == second.count, !first.isEmpty else { return .infinity }

        var squared: Float = 0
        vDSP_distancesq(first, 1, second, 1, &squared, vDSP_Length(first.count))
        return squared.squareRoot()
    }

    /// Every pair of prints closer than `threshold`, as index pairs with the smaller first.
    ///
    /// Compares all pairs in blocks with a matrix product, so a library of thousands of photos
    /// takes a moment instead of minutes: |a − b|² = |a|² + |b|² − 2 a·b.
    static func pairs(among prints: [[Float]], within threshold: Float, blockSize: Int = 256) -> [(Int, Int)] {
        let count = prints.count
        guard count > 1, let dimension = prints.first?.count, dimension > 0,
              prints.allSatisfy({ $0.count == dimension }) else { return [] }

        let matrix = prints.flatMap { $0 }
        let norms = prints.map { print in
            var sum: Float = 0
            vDSP_svesq(print, 1, &sum, vDSP_Length(dimension))
            return sum
        }
        let limit = threshold * threshold
        var found: [(Int, Int)] = []

        for rowStart in stride(from: 0, to: count, by: blockSize) {
            let rowEnd = min(rowStart + blockSize, count)
            let rows = rowEnd - rowStart
            for columnStart in stride(from: rowStart, to: count, by: blockSize) {
                let columnEnd = min(columnStart + blockSize, count)
                let columns = columnEnd - columnStart
                let products = blockProducts(matrix, dimension: dimension, rows: rowStart..<rowEnd, columns: columnStart..<columnEnd)
                for row in 0..<rows {
                    let first = rowStart + row
                    for column in 0..<columns {
                        let second = columnStart + column
                        guard second > first else { continue }

                        let squared = norms[first] + norms[second] - 2 * products[row * columns + column]
                        if squared <= limit {
                            found.append((first, second))
                        }
                    }
                }
            }
        }
        return found
    }

    /// The dot products of the prints in `rows` with those in `columns`, row by row.
    private static func blockProducts(_ matrix: [Float], dimension: Int, rows: Range<Int>, columns: Range<Int>) -> [Float] {
        let rowBlock = Array(matrix[(rows.lowerBound * dimension)..<(rows.upperBound * dimension)])
        let columnBlock = Array(matrix[(columns.lowerBound * dimension)..<(columns.upperBound * dimension)])
        var transposed = [Float](repeating: 0, count: columnBlock.count)
        // columnBlock is columns × dimension; transposed is dimension × columns.
        vDSP_mtrans(columnBlock, 1, &transposed, 1, vDSP_Length(dimension), vDSP_Length(columns.count))
        var products = [Float](repeating: 0, count: rows.count * columns.count)
        vDSP_mmul(rowBlock, 1, transposed, 1, &products, 1, vDSP_Length(rows.count), vDSP_Length(columns.count), vDSP_Length(dimension))
        return products
    }
}
