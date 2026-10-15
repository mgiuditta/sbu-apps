import Foundation

/// A search snippet with the matching words in bold, from SQLite's `snippet()` markers.
enum SearchSnippet {
    static func attributed(_ snippet: String) -> AttributedString {
        var result = AttributedString()
        var isMatch = false
        var run = ""
        func flush() {
            guard !run.isEmpty else { return }
            var part = AttributedString(run)
            if isMatch { part.inlinePresentationIntent = .stronglyEmphasized }
            result += part
            run = ""
        }
        for character in snippet {
            switch character {
            case SearchHit.matchStart:
                flush()
                isMatch = true
            case SearchHit.matchEnd:
                flush()
                isMatch = false
            default:
                run.append(character)
            }
        }
        flush()
        return result
    }
}
