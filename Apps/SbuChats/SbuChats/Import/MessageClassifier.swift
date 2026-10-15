import Foundation

/// Tells text, media, deleted and system messages apart, in the languages WhatsApp exports in.
///
/// Media markers change with the phone's language, so it relies on their shape first
/// (`<attached: 0000-PHOTO-….jpg>`, `IMG-…-WA0001.jpg (file attached)`, `<Media omitted>`,
/// a U+200E before "image omitted") and on short word lists only where the shape isn't enough.
nonisolated enum MessageClassifier {
    /// The kind of a message and its text without WhatsApp's markers.
    static func classify(sender: String?, body: String) -> (kind: MessageKind, text: String) {
        let startsWithMark = body.unicodeScalars.first?.value == 0x200E
        let text = stripEditedMarker(trimmed(body))
        guard sender != nil else { return (.system, text) }

        let firstLine = text.split(separator: "\n", maxSplits: 1, omittingEmptySubsequences: false).first.map(String.init) ?? text
        if isAttachment(firstLine) { return (.media, text) }
        if isOmittedMedia(text, startsWithMark: startsWithMark) { return (.omittedMedia, text) }
        if isDeleted(text) { return (.deleted, text) }
        // On iPhone the app marks its own lines (calls, encryption notice, group changes) with U+200E.
        if startsWithMark { return (.system, text) }
        return (.text, text)
    }

    /// The number of words a person wrote: runs between spaces that hold a letter or a digit.
    static func wordCount(_ text: String) -> Int {
        text.split(whereSeparator: \.isWhitespace).count { word in
            word.contains { $0.isLetter || $0.isNumber }
        }
    }

    // MARK: - Shapes

    /// `<attached: 00000012-PHOTO-2023-01-01-12-00-00.jpg>` (iPhone, any language) or
    /// `IMG-20230101-WA0001.jpg (file attached)` (Android, any language).
    private static func isAttachment(_ line: String) -> Bool {
        if line.hasPrefix("<"), line.hasSuffix(">"), let colon = line.firstIndex(of: ":") {
            let name = line[line.index(after: colon) ..< line.index(before: line.endIndex)].trimmingCharacters(in: .whitespaces)
            return hasFileExtension(name) && line.distance(from: line.startIndex, to: colon) <= 32
        }
        if line.hasSuffix(")"), let open = line.lastIndex(of: "(") {
            let name = line[..<open].trimmingCharacters(in: .whitespaces)
            return !name.contains(" ") && hasFileExtension(name) && name.contains("-")
        }
        return false
    }

    private static func hasFileExtension(_ name: String) -> Bool {
        guard let dot = name.lastIndex(of: "."), dot != name.startIndex else { return false }
        let fileExtension = name[name.index(after: dot)...]
        return (2 ... 5).contains(fileExtension.count) && fileExtension.allSatisfy { $0.isLetter || $0.isNumber }
    }

    /// Android `<Media omitted>` in any language, or iPhone's marked "image omitted".
    private static func isOmittedMedia(_ text: String, startsWithMark: Bool) -> Bool {
        let lowered = text.lowercased()
        if lowered.hasPrefix("<"), lowered.hasSuffix(">"), lowered.count <= 40,
           ["medi", "mídia", "medya", "multimedia"].contains(where: lowered.contains) {
            return true
        }
        let words = lowered.split(whereSeparator: \.isWhitespace)
        guard let last = words.last.map(String.init), omittedWords.contains(last) else { return false }
        return startsWithMark || words.count <= 3
    }

    private static func isDeleted(_ text: String) -> Bool {
        var lowered = text.lowercased()
        if lowered.hasSuffix(".") { lowered.removeLast() }
        return deletedSentences.contains(lowered)
    }

    /// Drops `<This message was edited>` and its translations from the end of a message.
    private static func stripEditedMarker(_ text: String) -> String {
        guard text.hasSuffix(">"), let open = text.lastIndex(of: "<") else { return text }
        let marker = text[open...].lowercased()
        guard editedWords.contains(where: marker.contains) else { return text }
        return trimmed(String(text[..<open]))
    }

    private static func trimmed(_ text: String) -> String {
        var scalars = Substring(text).unicodeScalars
        while let first = scalars.first, WhatsAppLineScanner.isMark(first) || first.properties.isWhitespace { scalars.removeFirst() }
        while let last = scalars.last, WhatsAppLineScanner.isMark(last) || last.properties.isWhitespace { scalars.removeLast() }
        return String(scalars)
    }

    // MARK: - Words

    /// The last word of iPhone's "image omitted" in English, Italian, Spanish, German, French,
    /// Portuguese, Dutch and Turkish.
    private static let omittedWords: Set<String> = [
        "omitted", "omessa", "omesso", "omessi", "omesse",
        "omitido", "omitida", "omitidos", "omitidas",
        "weggelassen", "ausgelassen",
        "absente", "absent", "omis", "omise", "omises",
        "ocultado", "ocultada", "oculto", "oculta",
        "weggelaten", "edilmedi",
    ]

    /// "This message was deleted" and "You deleted this message", in the same eight languages.
    private static let deletedSentences: Set<String> = [
        "this message was deleted", "you deleted this message",
        "questo messaggio è stato eliminato", "hai eliminato questo messaggio",
        "se eliminó este mensaje", "eliminaste este mensaje", "este mensaje fue eliminado",
        "diese nachricht wurde gelöscht", "du hast diese nachricht gelöscht",
        "ce message a été supprimé", "vous avez supprimé ce message",
        "esta mensagem foi apagada", "você apagou esta mensagem", "mensagem apagada",
        "dit bericht is verwijderd", "je hebt dit bericht verwijderd",
        "bu mesaj silindi", "bu mesajı sildiniz",
    ]

    private static let editedWords = ["edited", "modificato", "editado", "editada", "bearbeitet", "modifié", "bewerkt", "düzenlendi"]
}
