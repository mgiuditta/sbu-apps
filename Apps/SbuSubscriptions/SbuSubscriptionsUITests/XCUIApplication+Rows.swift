import XCTest

extension XCUIApplication {
    /// The home row whose label starts with `name`, scrolled into view: the figure zone fills the top of the screen,
    /// so the rows start below it. It looks down the list first, then back up.
    @MainActor
    func subscriptionRow(_ name: String) -> XCUIElement {
        let row = buttons.matching(NSPredicate(format: "label BEGINSWITH %@", name)).firstMatch
        for down in [true, true, true, true, true, true, false, false, false, false, false, false, false, false] {
            if row.exists, row.isHittable { break }
            if down { swipeUp(velocity: .slow) } else { swipeDown(velocity: .slow) }
        }
        return row
    }

    /// Scrolls the home back to its top, the figure zone.
    @MainActor
    func scrollHomeToTop() {
        for _ in 0..<4 {
            swipeDown(velocity: .fast)
        }
    }
}
