import Foundation

/// Turns what you type in the search field into an SQLite FTS5 query.
///
/// Words must all appear (AND), in any order, and match the start of a word: `cen` finds "cena".
/// Text in quotes is an exact phrase. `OR` between two terms finds either. Everything else is
/// quoted, so punctuation never becomes FTS syntax and never fails the query.
nonisolated enum SearchQuery {
    /// The FTS5 expression for `input`, or `nil` when there is nothing to search.
    static func match(for input: String) -> String? {
        var terms: [String] = []
        var pendingOr = false
        for token in tokens(in: input) {
            switch token {
            case .or:
                if !terms.isEmpty { pendingOr = true }
            case .and:
                continue
            case let .word(word):
                append(quoted(word) + "*", to: &terms, or: &pendingOr)
            case let .phrase(phrase):
                append(quoted(phrase), to: &terms, or: &pendingOr)
            }
        }
        return terms.isEmpty ? nil : terms.joined(separator: " ")
    }

    private enum Token: Equatable {
        case word(String)
        case phrase(String)
        case or
        case and
    }

    private static func append(_ term: String, to terms: inout [String], or pendingOr: inout Bool) {
        if pendingOr, let last = terms.popLast() {
            terms.append("(\(last) OR \(term))")
        } else {
            terms.append(term)
        }
        pendingOr = false
    }

    private static func quoted(_ text: String) -> String {
        "\"" + text.replacing("\"", with: "\"\"") + "\""
    }

    private static func tokens(in input: String) -> [Token] {
        var tokens: [Token] = []
        var current = ""
        var inPhrase = false

        func flushWord() {
            defer { current = "" }
            // Only letters and digits make a word; "-" or "?" alone match nothing.
            let word = current.filter { $0.isLetter || $0.isNumber || $0 == "'" || $0 == "’" }
            guard !word.isEmpty else { return }
            switch current {
            case "OR": tokens.append(.or)
            case "AND": tokens.append(.and)
            default: tokens.append(.word(word))
            }
        }

        for character in input {
            if character == "\"" || character == "“" || character == "”" {
                if inPhrase {
                    let phrase = current.trimmingCharacters(in: .whitespaces)
                    if !phrase.isEmpty { tokens.append(.phrase(phrase)) }
                    current = ""
                } else {
                    flushWord()
                }
                inPhrase.toggle()
            } else if character.isWhitespace, !inPhrase {
                flushWord()
            } else {
                current.append(character)
            }
        }
        if inPhrase {
            // An unclosed quote: still a phrase.
            let phrase = current.trimmingCharacters(in: .whitespaces)
            if !phrase.isEmpty { tokens.append(.phrase(phrase)) }
        } else {
            flushWord()
        }
        return tokens
    }
}
