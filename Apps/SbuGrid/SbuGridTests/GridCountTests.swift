import CoreGraphics
import Foundation
import Testing
@testable import SbuGrid

struct GridCountTests {
    @Test(arguments: [
        ("it_IT", 4, 6, "4 × 6"),
        ("en_US", 4, 6, "4 × 6"),
        ("it_IT", 12_345, 5, "12.345 × 5"),
        // Italian groups only from five digits.
        ("it_IT", 1_234, 5, "1234 × 5"),
        ("en_US", 1_234, 5, "1,234 × 5"),
        ("it_IT", 0, 0, "0 × 0"),
    ])
    func formatsColumnsByRows(locale: String, columns: Int, rows: Int, expected: String) {
        let style = GridCountFormatStyle(locale: Locale(identifier: locale))
        #expect(style.format(GridCount(columns: columns, rows: rows)) == expected)
    }

    @Test func theStyleTakesANewLocale() {
        let style = GridCountFormatStyle.gridCount.locale(Locale(identifier: "en_US"))
        #expect(style.locale.identifier == "en_US")
        #expect(style.format(GridCount(columns: 1_000, rows: 2)) == "1,000 × 2")
    }

    @Test func countsComeFromTheLayout() {
        let layout = GridLayout(size: CGSize(width: 1200, height: 1600), rule: .square(columns: 4))
        #expect(GridCount(layout) == GridCount(columns: 4, rows: 6))
    }

    @Test(arguments: [(1, 1), (4, 6), (12, 1), (1, 50)])
    func theSpokenCountSaysBothNumbers(columns: Int, rows: Int) {
        let spoken = GridCount(columns: columns, rows: rows).spoken
        #expect(spoken.contains(String(columns)))
        #expect(spoken.contains(String(rows)))
        #expect(spoken.contains("×") == false)
    }
}
