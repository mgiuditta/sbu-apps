import Foundation
import Testing
@testable import SbuGrid

struct GridSettingsTests {
    @Test func defaultsAreABeginnerSquareGrid() {
        let settings = GridSettings()
        #expect(settings.columns == 4)
        #expect(settings.rows == 6)
        #expect(settings.hasSquareCells)
        #expect(settings.lineTone == .dark)
        #expect(settings.lineWidth == 1)
        #expect(settings.opacity == 0.8)
        #expect(settings.showsDiagonals == false)
        #expect(settings.showsNumbers == false)
        #expect(settings.isBlackAndWhite == false)
    }

    @Test(arguments: [(-1_000, 1), (0, 1), (1, 1), (17, 17), (50, 50), (51, 50), (Int.max, 50), (Int.min, 1)])
    func columnsAndRowsStayInRange(value: Int, expected: Int) {
        var settings = GridSettings()
        settings.columns = value
        settings.rows = value
        #expect(settings.columns == expected)
        #expect(settings.rows == expected)
    }

    @Test(arguments: [
        (-5.0, 0.5), (0.0, 0.5), (0.5, 0.5), (2.5, 2.5), (8.0, 8.0), (8.1, 8.0),
        (Double.infinity, 8.0), (-Double.infinity, 0.5), (Double.nan, 0.5),
    ])
    func lineWidthStaysInRange(value: Double, expected: Double) {
        var settings = GridSettings()
        settings.lineWidth = value
        #expect(settings.lineWidth == expected)
    }

    @Test(arguments: [(-1.0, 0.1), (0.0, 0.1), (0.1, 0.1), (0.55, 0.55), (1.0, 1.0), (7.0, 1.0), (Double.nan, 0.1)])
    func opacityStaysInRange(value: Double, expected: Double) {
        var settings = GridSettings()
        settings.opacity = value
        #expect(settings.opacity == expected)
    }

    @Test func squareCellsFollowTheColumnsAndIgnoreTheRows() {
        var settings = GridSettings()
        settings.columns = 7
        settings.rows = 3
        settings.hasSquareCells = true
        #expect(settings.cellRule == .square(columns: 7))
        settings.hasSquareCells = false
        #expect(settings.cellRule == .divide(columns: 7, rows: 3))
    }

    @Test func roundTripsThroughJSON() throws {
        var settings = GridSettings()
        settings.columns = 12
        settings.rows = 9
        settings.lineWidth = 3.5
        settings.opacity = 0.35
        settings.lineTone = .light
        settings.hasSquareCells = false
        settings.showsDiagonals = true
        settings.showsNumbers = true
        settings.isBlackAndWhite = true
        let data = try JSONEncoder().encode(settings)
        #expect(try JSONDecoder().decode(GridSettings.self, from: data) == settings)
    }

    @Test func missingKeysTakeTheDefaults() throws {
        let decoded = try JSONDecoder().decode(GridSettings.self, from: Data(#"{"columns": 9}"#.utf8))
        var expected = GridSettings()
        expected.columns = 9
        #expect(decoded == expected)
    }

    @Test func absurdStoredValuesAreClampedWhenDecoded() throws {
        let json = #"{"columns": 0, "rows": 99999, "lineWidth": -3, "opacity": 40}"#
        let decoded = try JSONDecoder().decode(GridSettings.self, from: Data(json.utf8))
        #expect(decoded.columns == 1)
        #expect(decoded.rows == 50)
        #expect(decoded.lineWidth == 0.5)
        #expect(decoded.opacity == 1)
    }

    @Test func anUnknownToneFallsBackToDark() throws {
        let decoded = try JSONDecoder().decode(GridSettings.self, from: Data(#"{"lineTone": "sepia"}"#.utf8))
        #expect(decoded.lineTone == .dark)
    }

    @Test func aWrongTypeIsAnError() {
        #expect(throws: DecodingError.self) {
            try JSONDecoder().decode(GridSettings.self, from: Data(#"{"columns": "four"}"#.utf8))
        }
    }

    @Test func theStepsDivideTheRanges() {
        let widthSteps = (GridSettings.lineWidthRange.upperBound - GridSettings.lineWidthRange.lowerBound) / GridSettings.lineWidthStep
        let opacitySteps = (GridSettings.opacityRange.upperBound - GridSettings.opacityRange.lowerBound) / GridSettings.opacityStep
        #expect(widthSteps == widthSteps.rounded())
        #expect(abs(opacitySteps - opacitySteps.rounded()) < 1e-9)
    }
}
