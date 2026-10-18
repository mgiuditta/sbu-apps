import XCTest

/// Drags pieces onto the board as a player would, keeping a screenshot after each round.
final class PlayTests: XCTestCase {
    @MainActor
    func testDragPieces() {
        let app = XCUIApplication()
        app.launchArguments += ["-AppleLanguages", "(it)", "-AppleLocale", "it_IT", "-resetForUITests"]
        app.launch()
        let board = app.otherElements["Griglia"]
        XCTAssertTrue(board.waitForExistence(timeout: 5))
        // Finger targets on the board, as fractions of its side; the piece floats above the finger.
        let targets: [CGVector] = [
            CGVector(dx: 0.2, dy: 0.45), CGVector(dx: 0.55, dy: 0.45), CGVector(dx: 0.85, dy: 0.45),
            CGVector(dx: 0.2, dy: 0.8), CGVector(dx: 0.55, dy: 0.8), CGVector(dx: 0.85, dy: 0.8),
            CGVector(dx: 0.2, dy: 1.05), CGVector(dx: 0.55, dy: 1.05), CGVector(dx: 0.85, dy: 1.05),
            CGVector(dx: 0.4, dy: 0.6), CGVector(dx: 0.7, dy: 0.95), CGVector(dx: 0.1, dy: 0.6),
        ]
        for (index, target) in targets.enumerated() {
            let pieces = app.buttons.matching(NSPredicate(format: "label BEGINSWITH 'Pezzo da'"))
            guard pieces.count > 0 else { break }
            let piece = pieces.element(boundBy: index % pieces.count)
            piece.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
                .press(forDuration: 0.1, thenDragTo: board.coordinate(withNormalizedOffset: target), withVelocity: .slow, thenHoldForDuration: 0.2)
            if index % 3 == 2 {
                let shot = XCTAttachment(screenshot: app.screenshot())
                shot.name = "round-\(index / 3)"
                shot.lifetime = .keepAlways
                add(shot)
            }
        }
    }
}
