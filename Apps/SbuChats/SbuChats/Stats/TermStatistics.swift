import NaturalLanguage

/// The most used words and emoji, for everyone and for each person.
///
/// Words come from `NLTokenizer`, lowercased, without the stopwords of the chat's main language,
/// links, numbers and single letters. Emoji are counted per grapheme, so 👍🏽 and 👨‍👩‍👧 count as one each.
nonisolated struct TermStatistics: Equatable, Sendable {
    /// Everyone's most used words, most used first.
    let words: [RankedTerm]
    let emoji: [RankedTerm]
    let wordsBySender: [String: [RankedTerm]]
    let emojiBySender: [String: [RankedTerm]]

    static let empty = TermStatistics(texts: [])

    init(texts: [SenderText], limit: Int = 50) {
        let language = Self.dominantLanguage(of: texts)
        let stopwords = Stopwords.words(for: language)
        // Italian and French glue articles and prepositions to the next word: "dall'ufficio" is "ufficio".
        let elides = language == .italian || language == .french
        let tokenizer = NLTokenizer(unit: .word)
        var wordCounts: [String: [String: Int]] = [:]
        var emojiCounts: [String: [String: Int]] = [:]

        for message in texts {
            for character in message.text where character.isEmoji {
                emojiCounts[message.sender, default: [:]][String(character), default: 0] += 1
            }
            let text = Self.withoutLinks(message.text)
            tokenizer.string = text
            tokenizer.enumerateTokens(in: text.startIndex ..< text.endIndex) { range, _ in
                var word = text[range].lowercased().replacing("’", with: "'")
                if elides, let apostrophe = word.lastIndex(where: { $0 == "'" || $0 == "’" }),
                   word.distance(from: word.startIndex, to: apostrophe) <= 5 {
                    let tail = word[word.index(after: apostrophe)...]
                    if tail.count >= 2 { word = String(tail) }
                }
                if Self.isRankable(word), !stopwords.contains(word) {
                    wordCounts[message.sender, default: [:]][word, default: 0] += 1
                }
                return true
            }
        }

        words = Self.ranked(Self.merged(wordCounts), limit: limit)
        emoji = Self.ranked(Self.merged(emojiCounts), limit: limit)
        wordsBySender = wordCounts.mapValues { Self.ranked($0, limit: limit) }
        emojiBySender = emojiCounts.mapValues { Self.ranked($0, limit: limit) }
    }

    /// A word worth ranking: two or more characters, at least one letter, not a link.
    private static func isRankable(_ word: String) -> Bool {
        word.count >= 2 && word.contains(where: \.isLetter) && !word.hasPrefix("http") && !word.hasPrefix("www")
    }

    /// The text without web addresses, whose pieces aren't words anyone wrote.
    private static func withoutLinks(_ text: String) -> String {
        guard text.contains("http") || text.contains("www.") else { return text }
        return text.split(whereSeparator: \.isWhitespace)
            .filter { !$0.contains("http") && !$0.contains("www.") }
            .joined(separator: " ")
    }

    private static func merged(_ counts: [String: [String: Int]]) -> [String: Int] {
        counts.values.reduce(into: [:]) { total, counts in
            total.merge(counts, uniquingKeysWith: +)
        }
    }

    private static func ranked(_ counts: [String: Int], limit: Int) -> [RankedTerm] {
        counts.sorted { $0.value != $1.value ? $0.value > $1.value : $0.key < $1.key }
            .prefix(limit)
            .map { RankedTerm(term: $0.key, count: $0.value) }
    }

    /// The language most of the chat is written in, from a sample of its messages.
    private static func dominantLanguage(of texts: [SenderText]) -> NLLanguage? {
        let recognizer = NLLanguageRecognizer()
        let step = max(1, texts.count / 2000)
        var sample = ""
        for index in stride(from: 0, to: texts.count, by: step) {
            sample += texts[index].text
            sample += "\n"
        }
        recognizer.processString(sample)
        return recognizer.dominantLanguage
    }
}
