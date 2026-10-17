import CoreText
import SwiftUI
import Testing
@testable import SbuKit

/// The figure sits on the grid, narrows instead of wrapping, and stays one line up to AX5.
struct FigureTests {
    @Test(arguments: [("12", 216.0), ("120", 192), ("0,0°", 168), ("47,90 €", 144), ("1.234.567", 144)])
    func heroSizeIsWholeCells(text: String, size: Double) {
        let hero = SbuFigure.heroSize(for: text)
        #expect(Double(hero) == size)
        #expect(hero.truncatingRemainder(dividingBy: SbuTheme.gridCell) == 0)
    }

    @Test(arguments: [(0.0, 0.0), (24, 0), (10, 14), (23.8, 0), (49, 23)])
    func offsetReachesTheNextGridLine(minY: Double, offset: Double) {
        #expect(abs(SbuFigure.offsetToGrid(minY) - offset) < 0.01)
    }

    /// At AX5 on an iPhone width, every figure renders on one line: two lines would at least double
    /// the block, which is as tall as its hero size plus the offset to the next grid line.
    @Test(arguments: ["12", "0,0°", "47,90 €", "1.234,56 €"])
    func figureStaysOnOneLineAtAX5(text: String) throws {
        let figure = SbuFigure(value: text)
            .frame(width: 358)
            .dynamicTypeSize(.accessibility5)
            .environment(\.sbuAccent, .habits)
        let renderer = ImageRenderer(content: figure)
        renderer.proposedSize = ProposedViewSize(width: 358, height: nil)
        let image = try #require(renderer.uiImage)

        let block = SbuFigure.heroSize(for: text) + SbuFigure.descentInCells(size: SbuFigure.heroSize(for: text))
        #expect(image.size.height <= block)
    }

    @Test(arguments: [144.0, 216])
    func descentIsWholeCells(size: Double) {
        let descent = SbuFigure.descentInCells(size: size)
        #expect(descent > 0)
        #expect(descent.truncatingRemainder(dividingBy: SbuTheme.gridCell) == 0)
    }

    @Test(arguments: [75.0, 87, 100])
    func figureFontTakesTheWidthAxis(width: Double) throws {
        let font = SbuFont.figure(size: 144, width: width)
        // Core Text leaves out axes at their default: wdth 100, wght 800, opsz 96.
        let variation = CTFontCopyVariation(font) as? [Int: Double] ?? [:]

        #expect(variation[SbuFont.Axis.width, default: 100] == width)
        #expect(variation[SbuFont.Axis.weight, default: 800] == 800)
        #expect(variation[SbuFont.Axis.opticalSize, default: 96] == 96)
    }

    @Test func narrowerWidthIsNarrower() {
        let wide = width(of: "47,90", font: SbuFont.figure(size: 144, width: 100))
        let narrow = width(of: "47,90", font: SbuFont.figure(size: 144, width: 75))
        #expect(narrow < wide)
    }

    @Test(arguments: ["1111", "7777"])
    func figureFontHasTabularFigures(digits: String) {
        let font = SbuFont.figure(size: 144, width: 87)
        #expect(abs(width(of: digits, font: font) - width(of: "0000", font: font)) <= 1)
    }

    @Test func cartiglioFontIsPlexMono() throws {
        #expect(SbuFont.isRegistered)
        let font = try #require(UIFont(name: SbuFont.monoPostScriptName, size: SbuTheme.cartiglioSize))
        #expect(font.familyName == "IBM Plex Mono")
    }

    @Test func paperGridFallsOnTheMargin() {
        let path = SbuPaper.lines(in: CGSize(width: 48, height: 48), top: 0)
        #expect(path.contains(CGPoint(x: SbuTheme.gridOffset, y: 30)))
        #expect(path.contains(CGPoint(x: 30, y: 0.2)))
        #expect(!path.contains(CGPoint(x: 30, y: 30)))
    }

    private func width(of text: String, font: CTFont) -> CGFloat {
        (text as NSString).size(withAttributes: [.font: font as UIFont]).width
    }
}
