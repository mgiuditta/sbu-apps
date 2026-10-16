import Foundation
import Testing
@testable import SbuGrid

struct GridFigureTests {
    let italian = Locale(identifier: "it_IT")

    @Test func withoutASheetTheFigureIsTheCount() {
        let count = GridCount(columns: 4, rows: 6)
        let figure = GridFigure(paper: PaperSettings(locale: italian), settings: GridSettings(), count: count, locale: italian)
        #expect(figure.kind == .count(count))
        #expect(figure.spoken == count.spoken)
        #expect(figure.context != nil)
    }

    @Test func freeCellsHaveNoContextLine() {
        var settings = GridSettings()
        settings.hasSquareCells = false
        let figure = GridFigure(paper: PaperSettings(locale: italian), settings: settings, count: GridCount(columns: 2, rows: 2), locale: italian)
        #expect(figure.context == nil)
    }

    @Test func withASheetTheFigureIsTheCell() throws {
        var paper = PaperSettings(locale: italian)
        paper.format = .a4
        paper.cellLength = 2.5
        let figure = GridFigure(paper: paper, settings: GridSettings(), count: GridCount(columns: 9, rows: 12), locale: italian)
        #expect(figure.kind == .cell(length: 2.5, unit: .centimeters))
        #expect(figure.spoken == "2,5 centimetri")
        let context = try #require(figure.context)
        #expect(context.contains("A4"))
        #expect(context.contains("9 × 12"))
    }

    @Test func theCellFollowsTheUnit() {
        var paper = PaperSettings(locale: Locale(identifier: "en_US"))
        paper.format = .letter
        let figure = GridFigure(paper: paper, settings: GridSettings(), count: GridCount(columns: 12, rows: 15), locale: Locale(identifier: "en_US"))
        #expect(figure.kind == .cell(length: 0.75, unit: .inches))
        #expect(figure.spoken == "0.75 inches")
    }
}
