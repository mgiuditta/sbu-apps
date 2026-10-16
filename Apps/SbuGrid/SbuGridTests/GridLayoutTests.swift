import CoreGraphics
import Testing
@testable import SbuGrid

struct GridLayoutTests {
    @Test func dividesThePictureIntoEqualCells() {
        let layout = GridLayout(size: CGSize(width: 400, height: 600), rule: .divide(columns: 4, rows: 3))
        #expect(layout.columnCount == 4)
        #expect(layout.rowCount == 3)
        #expect(layout.verticalLines == [100, 200, 300])
        #expect(layout.horizontalLines == [200, 400])
        #expect(layout.isEmpty == false)
    }

    @Test(arguments: [
        // 1200 × 1600 with 4 square columns: 300-pixel cells, 1600 / 300 = 5.33, so 6 rows, the last cut.
        (4, CGSize(width: 1200, height: 1600), 6),
        // Exactly 4 cells tall.
        (3, CGSize(width: 300, height: 400), 4),
        // Landscape: fewer rows than columns.
        (8, CGSize(width: 1600, height: 900), 5),
        (1, CGSize(width: 1000, height: 10), 1),
        (50, CGSize(width: 500, height: 5000), 500 > GridLayout.maximumCount ? 0 : 500),
    ])
    func squareCellsCountTheirRows(columns: Int, size: CGSize, rows: Int) {
        let layout = GridLayout(size: size, rule: .square(columns: columns))
        #expect(layout.rowCount == rows)
        if rows > 0 {
            #expect(layout.cell.width == layout.cell.height)
            #expect(layout.horizontalLines.count == rows - 1)
        }
    }

    @Test func aLastRowCutWhereThePictureEnds() throws {
        let layout = GridLayout(size: CGSize(width: 1200, height: 1600), rule: .square(columns: 4))
        #expect(layout.horizontalLines == [300, 600, 900, 1200, 1500])
        // The numbers sit in the middle of what shows of the cut row: 1500…1600.
        let lastRow = try #require(layout.rowCenters.last)
        #expect(lastRow == 1550)
        #expect(layout.rowCenters.first == 150)
    }

    @Test func aSheetRuledFromTheCorner() {
        // A4 portrait, 2 cm cells: 10.5 columns and 14.85 rows, so 11 and 15, the last ones cut.
        let layout = GridLayout(size: CGSize(width: 2100, height: 2970), rule: .physical(cellLength: 2, paperWidth: 21))
        #expect(layout.columnCount == 11)
        #expect(layout.rowCount == 15)
        #expect(layout.verticalLines.first == 200)
        #expect(layout.verticalLines.last == 2000)
        #expect(layout.horizontalLines.last == 2800)
    }

    @Test(arguments: [
        (CGFloat(400), CGFloat(100), 4),
        (CGFloat(400.0001), CGFloat(100), 4),
        (CGFloat(400.5), CGFloat(100), 5),
        (CGFloat(399.9), CGFloat(100), 4),
        (CGFloat(50), CGFloat(100), 1),
        (CGFloat(100), CGFloat(100), 1),
        (CGFloat(0), CGFloat(100), 0),
        (CGFloat(100), CGFloat(0), 0),
        (CGFloat(-100), CGFloat(10), 0),
        (CGFloat.nan, CGFloat(10), 0),
        (CGFloat(100), CGFloat.infinity, 0),
        (CGFloat.infinity, CGFloat(10), 0),
    ])
    func countsCellsIgnoringRounding(length: CGFloat, step: CGFloat, expected: Int) {
        #expect(GridLayout.count(length: length, step: step) == expected)
    }

    @Test func aGridTooDenseToSeeIsNotDrawn() {
        let layout = GridLayout(size: CGSize(width: 1000, height: 1000), rule: .physical(cellLength: 0.01, paperWidth: 100))
        #expect(layout.isEmpty)
        #expect(layout.verticalLines.isEmpty)
        #expect(layout.diagonals.isEmpty)
        #expect(layout.columnCenters.isEmpty)
        #expect(layout.strokeWidth(for: 2) == 0)
        #expect(layout.numberSize == 0)
    }

    @Test func theDensestAllowedGridIsDrawn() {
        let layout = GridLayout(size: CGSize(width: 400, height: 400), rule: .divide(columns: 400, rows: 400))
        #expect(layout.columnCount == GridLayout.maximumCount)
        #expect(layout.verticalLines.count == GridLayout.maximumCount - 1)
    }

    @Test(arguments: [CGSize.zero, CGSize(width: -10, height: 10), CGSize(width: CGFloat.nan, height: 10)])
    func anAbsurdPictureHasNoGrid(size: CGSize) {
        let layout = GridLayout(size: size, rule: .square(columns: 4))
        #expect(layout.isEmpty)
        #expect(layout.rowCount == 0)
        #expect(layout.scale == 0)
    }

    @Test func linesAreSortedAndInsideThePicture() {
        for columns in 1...50 {
            let size = CGSize(width: 1179, height: 2556)
            let layout = GridLayout(size: size, rule: .square(columns: columns))
            #expect(layout.verticalLines == layout.verticalLines.sorted())
            #expect(layout.verticalLines.allSatisfy { $0 > 0 && $0 < size.width })
            #expect(layout.horizontalLines.allSatisfy { $0 > 0 && $0 < size.height })
            #expect(layout.columnCount == columns)
        }
    }

    @Test func everyCellHasTwoDiagonalsCrossingAtItsCentre() throws {
        let layout = GridLayout(size: CGSize(width: 200, height: 300), rule: .divide(columns: 2, rows: 3))
        #expect(layout.diagonals.count == 2 * 3 * 2)
        let first = try #require(layout.diagonals.first)
        #expect(first == GridSegment(start: .zero, end: CGPoint(x: 100, y: 100)))
        let second = layout.diagonals[1]
        #expect(second == GridSegment(start: CGPoint(x: 100, y: 0), end: CGPoint(x: 0, y: 100)))
    }

    @Test func diagonalsOfACutCellKeepTheirAngle() throws {
        // The last row is cut at 1600: its diagonals still run a whole 300-pixel cell.
        let layout = GridLayout(size: CGSize(width: 1200, height: 1600), rule: .square(columns: 4))
        let last = try #require(layout.diagonals.last)
        #expect(abs(last.end.x - last.start.x) == abs(last.end.y - last.start.y))
        #expect(max(last.start.y, last.end.y) == 1800)
    }

    @Test func columnNumbersSitInTheMiddleOfEachColumn() {
        let layout = GridLayout(size: CGSize(width: 2100, height: 2970), rule: .physical(cellLength: 2, paperWidth: 21))
        #expect(layout.columnCenters.first == 100)
        // The cut column runs from 2000 to 2100.
        #expect(layout.columnCenters.last == 2050)
        #expect(layout.columnCenters.count == layout.columnCount)
        #expect(layout.rowCenters.count == layout.rowCount)
    }

    @Test(arguments: [
        (CGSize(width: 360, height: 640), CGFloat(1)),
        (CGSize(width: 640, height: 360), CGFloat(1)),
        (CGSize(width: 3600, height: 4800), CGFloat(10)),
        (CGSize(width: 180, height: 180), CGFloat(0.5)),
    ])
    func strokesGrowWithTheShorterSide(size: CGSize, scale: CGFloat) {
        let layout = GridLayout(size: size, rule: .square(columns: 2))
        #expect(layout.scale == scale)
        #expect(layout.strokeWidth(for: 1) == scale)
    }

    @Test func aStrokeIsNeverWiderThanAFifthOfACell() {
        let layout = GridLayout(size: CGSize(width: 360, height: 360), rule: .square(columns: 50))
        // 7.2-point cells: at most 1.44 points of line.
        #expect(abs(layout.strokeWidth(for: 8) - 1.44) < 1e-9)
    }

    @Test(arguments: [0.0, -1.0, Double.nan, Double.infinity])
    func anAbsurdLineWidthDrawsNothing(lineWidth: Double) {
        let layout = GridLayout(size: CGSize(width: 360, height: 360), rule: .square(columns: 4))
        #expect(layout.strokeWidth(for: lineWidth) == 0)
    }

    @Test(arguments: [(1, CGFloat(14)), (4, CGFloat(14)), (20, CGFloat(8)), (50, CGFloat(8)), (12, CGFloat(10))])
    func numbersAreAThirdOfACellBetween8And14Points(columns: Int, expected: CGFloat) {
        let layout = GridLayout(size: CGSize(width: 360, height: 360), rule: .square(columns: columns))
        #expect(abs(layout.numberSize - expected) < 1e-9)
    }

    @Test func theExportLooksLikeTheScreen() {
        // The same grid at screen size and at the photo's pixels: every length grows by the same factor.
        let screen = GridLayout(size: CGSize(width: 360, height: 480), rule: .square(columns: 6))
        let photo = GridLayout(size: CGSize(width: 3024, height: 4032), rule: .square(columns: 6))
        let factor = photo.size.width / screen.size.width
        #expect(screen.rowCount == photo.rowCount)
        #expect(abs(photo.strokeWidth(for: 2) - screen.strokeWidth(for: 2) * factor) < 1e-9)
        #expect(abs(photo.numberSize - screen.numberSize * factor) < 1e-9)
        for (small, large) in zip(screen.horizontalLines, photo.horizontalLines) {
            #expect(abs(large - small * factor) < 1e-6)
        }
    }
}
