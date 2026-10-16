import XCTest

extension XCUIElement {
    /// Replaces the field's text: deletes what is there, then types `text`.
    @MainActor
    func clearAndType(_ text: String) {
        tap()
        let current = value as? String ?? ""
        typeText(String(repeating: XCUIKeyboardKey.delete.rawValue, count: current.count) + text)
    }
}
