/// The game settings, the original's defaults: everything on.
nonisolated struct Preferences: Codable, Hashable, Sendable {
    var rules = Rules()
    /// The third mistake ends the game. A game keeps the value it started with, unless it is turned off.
    var hasMistakeLimit = true
    var highlightsDuplicates = true
    /// The row, column and box of the selected cell.
    var highlightsAreas = true
    /// The cells and notes with the selected cell's digit.
    var highlightsSameDigits = true
    /// A digit that is already on the grid nine times can no longer be tapped.
    var disablesUsedDigits = true
    var showsTimer = true
}
