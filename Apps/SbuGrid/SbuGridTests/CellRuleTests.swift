import CoreGraphics
import Testing
@testable import SbuGrid

struct CellRuleTests {
    @Test(arguments: [
        (CellRule.divide(columns: 4, rows: 6), CGSize(width: 400, height: 600), CGSize(width: 100, height: 100)),
        (CellRule.divide(columns: 3, rows: 2), CGSize(width: 300, height: 300), CGSize(width: 100, height: 150)),
        (CellRule.square(columns: 4), CGSize(width: 400, height: 1000), CGSize(width: 100, height: 100)),
        (CellRule.square(columns: 1), CGSize(width: 1200, height: 1600), CGSize(width: 1200, height: 1200)),
        // A4 is 21 cm wide: 2 cm cells on a 2100-pixel picture are 200 pixels.
        (CellRule.physical(cellLength: 2, paperWidth: 21), CGSize(width: 2100, height: 2970), CGSize(width: 200, height: 200)),
        (CellRule.physical(cellLength: 1, paperWidth: 8.5), CGSize(width: 850, height: 1100), CGSize(width: 100, height: 100)),
    ])
    func sizesTheCells(rule: CellRule, size: CGSize, expected: CGSize) {
        let cell = rule.cellSize(in: size)
        #expect(abs(cell.width - expected.width) < 1e-9)
        #expect(abs(cell.height - expected.height) < 1e-9)
    }

    @Test(arguments: [
        CellRule.divide(columns: 0, rows: 4),
        CellRule.divide(columns: 4, rows: 0),
        CellRule.divide(columns: -2, rows: -2),
        CellRule.square(columns: 0),
        CellRule.square(columns: -1),
        CellRule.physical(cellLength: 0, paperWidth: 21),
        CellRule.physical(cellLength: -2, paperWidth: 21),
        CellRule.physical(cellLength: 2, paperWidth: 0),
        CellRule.physical(cellLength: .nan, paperWidth: 21),
        CellRule.physical(cellLength: 2, paperWidth: .infinity),
    ])
    func absurdRulesHaveNoCells(rule: CellRule) {
        #expect(rule.cellSize(in: CGSize(width: 400, height: 600)) == .zero)
    }

    @Test(arguments: [
        CGSize.zero,
        CGSize(width: 0, height: 600),
        CGSize(width: 400, height: -1),
        CGSize(width: CGFloat.nan, height: 600),
        CGSize(width: 400, height: CGFloat.infinity),
    ])
    func absurdPicturesHaveNoCells(size: CGSize) {
        #expect(CellRule.square(columns: 4).cellSize(in: size) == .zero)
        #expect(CellRule.divide(columns: 4, rows: 4).cellSize(in: size) == .zero)
        #expect(CellRule.physical(cellLength: 2, paperWidth: 21).cellSize(in: size) == .zero)
    }
}
