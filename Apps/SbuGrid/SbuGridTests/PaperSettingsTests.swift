import CoreGraphics
import Foundation
import Testing
@testable import SbuGrid

struct PaperSettingsTests {
    private func paper(_ format: PaperFormat, _ orientation: PaperOrientation = .portrait, locale: String = "it_IT") -> PaperSettings {
        var paper = PaperSettings(locale: Locale(identifier: locale))
        paper.format = format
        paper.orientation = orientation
        return paper
    }

    @Test func startsWithoutASheetInTheRegionsUnit() {
        let metric = PaperSettings(locale: Locale(identifier: "it_IT"))
        #expect(metric.format == .free)
        #expect(metric.unit == .centimeters)
        #expect(metric.cellLength == 2)
        #expect(metric.size == nil)
        #expect(metric.aspectRatio == nil)
        #expect(metric.cellRule == nil)
        #expect(metric.pageSize == nil)

        let us = PaperSettings(locale: Locale(identifier: "en_US"))
        #expect(us.unit == .inches)
        #expect(us.cellLength == 0.75)
        #expect(us.customWidth == 12)
    }

    @Test(arguments: [
        (PaperFormat.a5, 14.8, 21.0),
        (.a4, 21.0, 29.7),
        (.a3, 29.7, 42.0),
        (.letter, 21.59, 27.94),
    ])
    func standardSheetsInCentimetres(format: PaperFormat, width: Double, height: Double) throws {
        let size = try #require(paper(format).size)
        #expect(abs(size.width - width) < 1e-9)
        #expect(abs(size.height - height) < 1e-9)
    }

    @Test func letterInInchesIsEightAndAHalfByEleven() throws {
        let size = try #require(paper(.letter, locale: "en_US").size)
        #expect(abs(size.width - 8.5) < 1e-9)
        #expect(abs(size.height - 11) < 1e-9)
    }

    @Test(arguments: [PaperFormat.a5, .a4, .a3, .letter, .custom])
    func landscapeSwapsTheSides(format: PaperFormat) throws {
        let portrait = try #require(paper(format).size)
        let landscape = try #require(paper(format, .landscape).size)
        #expect(portrait.width == landscape.height)
        #expect(portrait.height == landscape.width)
        let ratio = try #require(paper(format).aspectRatio)
        let turned = try #require(paper(format, .landscape).aspectRatio)
        #expect(abs(ratio * turned - 1) < 1e-9)
    }

    @Test func aFourGivesTheCellRuleAndThePage() throws {
        let a4 = paper(.a4)
        #expect(a4.cellRule == .physical(cellLength: 2, paperWidth: 21))
        let page = try #require(a4.pageSize)
        // ISO A4: 595 × 842 points.
        #expect(abs(page.width - 595.28) < 0.01)
        #expect(abs(page.height - 841.89) < 0.01)
    }

    @Test func letterPageIs612By792Points() throws {
        let page = try #require(paper(.letter, locale: "en_US").pageSize)
        #expect(abs(page.width - 612) < 1e-9)
        #expect(abs(page.height - 792) < 1e-9)
    }

    @Test func theCustomSheetUsesItsSides() throws {
        var custom = paper(.custom)
        custom.customWidth = 50
        custom.customHeight = 35
        let size = try #require(custom.size)
        #expect(size.width == 50)
        #expect(size.height == 35)
        #expect(custom.cellRule == .physical(cellLength: 2, paperWidth: 50))
    }

    @Test(arguments: [(-4.0, 0.5), (0.0, 0.5), (0.3, 0.5), (2.2, 2.0), (3.3, 3.5), (10.0, 10.0), (55.0, 10.0), (Double.nan, 0.5)])
    func cellsInCentimetresStayOnHalves(value: Double, expected: Double) {
        var settings = paper(.a4)
        settings.cellLength = value
        #expect(settings.cellLength == expected)
    }

    @Test(arguments: [(0.1, 0.25), (0.6, 0.5), (0.65, 0.75), (9.0, 4.0)])
    func cellsInInchesStayOnQuarters(value: Double, expected: Double) {
        var settings = paper(.a4, locale: "en_US")
        settings.cellLength = value
        #expect(settings.cellLength == expected)
    }

    @Test(arguments: [(1.0, 5.0), (12.25, 12.5), (400.0, 150.0), (-1.0, 5.0)])
    func customSidesStayInRange(value: Double, expected: Double) {
        var settings = paper(.custom)
        settings.customWidth = value
        settings.customHeight = value
        #expect(settings.customWidth == expected)
        #expect(settings.customHeight == expected)
    }

    @Test func changingTheUnitConvertsEveryLength() {
        var settings = paper(.custom)
        settings.cellLength = 2
        settings.customWidth = 30
        settings.customHeight = 40
        settings.unit = .inches
        #expect(settings.unit == .inches)
        #expect(settings.cellLength == 0.75)
        // 30 cm is 11.81 in, 40 cm 15.75 in.
        #expect(settings.customWidth == 11.75)
        #expect(settings.customHeight == 15.75)
        settings.unit = .centimeters
        #expect(settings.cellLength == 2)
        #expect(settings.customWidth == 30)
        #expect(settings.customHeight == 40)
    }

    @Test func choosingTheSameUnitChangesNothing() {
        var settings = paper(.a4)
        settings.cellLength = 3.5
        settings.unit = .centimeters
        #expect(settings.cellLength == 3.5)
    }

    @Test func theSheetSizeFollowsTheUnit() throws {
        var a4 = paper(.a4)
        a4.unit = .inches
        let size = try #require(a4.size)
        #expect(abs(size.width - 8.267_716_535) < 1e-6)
        // The page is the same paper whatever the unit.
        let page = try #require(a4.pageSize)
        #expect(abs(page.width - 595.28) < 0.01)
    }

    @Test func roundTripsThroughJSON() throws {
        var settings = paper(.custom, .landscape)
        settings.customWidth = 42
        settings.cellLength = 1.5
        let data = try JSONEncoder().encode(settings)
        #expect(try JSONDecoder().decode(PaperSettings.self, from: data) == settings)
    }

    @Test func storedInchesComeBackInInches() throws {
        var settings = paper(.letter, locale: "en_US")
        settings.cellLength = 1.25
        let decoded = try JSONDecoder().decode(PaperSettings.self, from: JSONEncoder().encode(settings))
        #expect(decoded.unit == .inches)
        #expect(decoded.cellLength == 1.25)
    }

    @Test func absurdOrUnknownStoredValuesAreFixed() throws {
        let json = #"{"format": "b4", "orientation": "diagonal", "unit": "centimeters", "cellLength": -9, "customWidth": 1e9, "customHeight": "tall"}"#
        let decoded = try JSONDecoder().decode(PaperSettings.self, from: Data(json.utf8))
        #expect(decoded.format == .free)
        #expect(decoded.orientation == .portrait)
        #expect(decoded.cellLength == 0.5)
        #expect(decoded.customWidth == 150)
        #expect(decoded.customHeight == 40)
    }

    @Test(arguments: PaperFormat.allCases)
    func everyFormatHasASizeExceptNone(format: PaperFormat) {
        #expect((paper(format).size == nil) == (format == .free))
        #expect(format.isSheet == (format != .free))
    }

    @Test func noneComesFirstAndCustomLast() {
        #expect(PaperFormat.allCases.first == .free)
        #expect(PaperFormat.allCases.last == .custom)
    }
}
