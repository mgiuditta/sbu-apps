import Foundation
import Testing
import UIKit
@testable import SbuKit

@MainActor
struct FigureCardTests {
    @Test(arguments: ["12", "544,34 €", "1.237,83 €"])
    func theCardIs1080By1350Pixels(value: String) throws {
        let card = SbuFigureCardImage(value: value, word: "all'anno", appName: "Sbu Subscriptions", accent: .subscriptions)
        let image = try #require(UIImage(data: try card.pngData()))
        #expect(image.size.width * image.scale == 1080)
        #expect(image.size.height * image.scale == 1350)
    }

    @Test func theSignatureNamesTheAppAndTheSite() {
        #expect(SbuFigureCard.signature(appName: "Sbu Habits") == "SBU HABITS · SBU.DEV")
    }
}
