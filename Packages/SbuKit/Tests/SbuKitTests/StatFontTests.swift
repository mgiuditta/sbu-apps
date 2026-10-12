import SwiftUI
import Testing
import UIKit
@testable import SbuKit

/// `stat` and `statHero` use the Bricolage Grotesque bundled with SbuKit, with tabular figures.
struct StatFontTests {
    @Test func bundledFontRegistersAndResolves() throws {
        #expect(SbuFont.isRegistered)

        let font = try #require(UIFont(name: SbuFont.statPostScriptName, size: SbuTheme.statSize))
        #expect(font.familyName == "Bricolage Grotesque")
    }

    @Test func licenseShipsWithTheFont() throws {
        let url = try #require(SbuFont.licenseURL)
        let notice = try String(contentsOf: url, encoding: .utf8)

        #expect(notice.hasPrefix("Copyright 2022 The Bricolage Grotesque Project Authors"))
        #expect(notice.contains("SIL OPEN FONT LICENSE Version 1.1"))
    }

    @Test func numberFontIsTheBundledFace() {
        let expected = Font.custom(SbuFont.statPostScriptName, fixedSize: 40).monospacedDigit()

        #expect(SbuTheme.numberFont(size: 40) == expected)
        #expect(SbuTheme.stat == expected)
    }

    /// The face is proportional by default ("1" is narrower than "0"): the figures must come out
    /// tabular, so a changing value keeps its width.
    @Test(arguments: ["1111", "7777", "2580"])
    func numberFontHasTabularFigures(digits: String) throws {
        let reference = try renderedWidth(of: "0000")
        let width = try renderedWidth(of: digits)

        #expect(abs(width - reference) <= 1, "\(digits): \(width) vs \(reference)")
    }

    @Test func faceIsProportionalWithoutTheFeature() throws {
        try #require(SbuFont.isRegistered)
        let font = try #require(UIFont(name: SbuFont.statPostScriptName, size: 64))
        let one = ("1111" as NSString).size(withAttributes: [.font: font]).width
        let zero = ("0000" as NSString).size(withAttributes: [.font: font]).width

        #expect(one < zero)
    }

    private func renderedWidth(of digits: String) throws -> CGFloat {
        let renderer = ImageRenderer(content: Text(verbatim: digits).font(SbuTheme.numberFont(size: 64)).fixedSize())
        let image = try #require(renderer.uiImage)
        return image.size.width
    }
}
