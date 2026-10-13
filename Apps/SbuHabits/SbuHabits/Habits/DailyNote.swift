import Foundation

/// The rules of a Nota del giorno: plain text, trimmed, never blank, at most `maxLength` characters.
nonisolated enum DailyNote {
    /// Longest note a day can hold: a few lines about how it went, not a diary. Streaks publishes
    /// no limit; 500 characters fit the editor without scrolling at default text size and keep a
    /// year of notes on every habit small enough for the widget, which reads the whole file.
    static let maxLength = 500

    /// `text` as it is saved: trimmed at both ends and cut to `maxLength`, or `nil` for a blank
    /// note, which is no note.
    static func normalized(_ text: String) -> String? {
        let cut = trimmed(String(trimmed(text).prefix(maxLength)))
        return cut.isEmpty ? nil : cut
    }

    /// `text` while it is being typed: only cut to `maxLength`, so spaces and new lines stay.
    static func limited(_ text: String) -> String {
        text.count > maxLength ? String(text.prefix(maxLength)) : text
    }

    /// A note the editor could have saved, for Importa.
    static func isPlausible(_ text: String) -> Bool {
        normalized(text) == text
    }

    private static func trimmed(_ text: String) -> String {
        text.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
