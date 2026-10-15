import Foundation

/// A made-up chat between two invented people, written by Sbu, in the iPhone export format.
///
/// For "Prova con una chat di esempio" (and the App Review, who has no chat to export), the
/// screenshots and the flow tests. Generated, not bundled: the same seed always writes the same
/// chat, about fourteen months long, ending the day before `end`.
nonisolated enum SampleChat {
    enum Language: Sendable {
        case italian
        case english
    }

    /// Who is you in the sample, by language.
    static func owner(_ language: Language) -> String {
        language == .italian ? "Giulia" : "Emma"
    }

    static func other(_ language: Language) -> String {
        language == .italian ? "Marco" : "Jack"
    }

    /// The file name, which becomes the chat's name.
    static func fileName(_ language: Language) -> String {
        language == .italian ? "Chat di esempio.txt" : "Sample chat.txt"
    }

    /// The language of the app's interface.
    static var appLanguage: Language {
        Bundle.main.preferredLocalizations.first == "it" ? .italian : .english
    }

    /// The export's text.
    static func text(_ language: Language, endingBefore end: Date, calendar: Calendar = .current) -> String {
        var random = SplitMix64(seed: 2026)
        let lastDay = calendar.date(byAdding: .day, value: -1, to: calendar.startOfDay(for: end)) ?? end
        let firstDay = calendar.date(byAdding: .day, value: -425, to: lastDay) ?? lastDay
        let you = owner(language)
        let them = other(language)
        let phrases = language == .italian ? italianPhrases : englishPhrases
        let emoji = ["😂", "❤️", "👍", "😍", "🙈", "🎉", "😘", "🍕", "☕️", "👍🏽"]
        var lines: [String] = []

        var day = firstDay
        while day <= lastDay {
            // Most days, one to three conversations; weekends a bit more.
            let weekday = calendar.component(.weekday, from: day)
            let chance = weekday == 1 || weekday == 7 ? 0.9 : 0.75
            if random.nextDouble() < chance {
                let conversations = 1 + random.next(below: 3)
                var hours = (0 ..< conversations).map { _ in hourOfConversation(&random) }
                hours.sort()
                for hour in hours {
                    var moment = calendar.date(bySettingHour: hour, minute: random.next(below: 60), second: random.next(below: 60), of: day) ?? day
                    let messages = 2 + random.next(below: 12)
                    var sender = random.nextDouble() < 0.55 ? you : them
                    for _ in 0 ..< messages {
                        var body = phrases[random.next(below: phrases.count)]
                        let roll = random.nextDouble()
                        if roll < 0.06 {
                            body = "\u{200E}" + (language == .italian ? "immagine omessa" : "image omitted")
                        } else if roll < 0.35 {
                            body += " " + emoji[random.next(below: emoji.count)]
                        }
                        lines.append(header(moment, language: language, calendar: calendar) + " \(sender): " + body)
                        // Marco answers a little slower than Giulia.
                        let pause = sender == you ? 20 + random.next(below: 400) : 40 + random.next(below: 900)
                        moment = moment.addingTimeInterval(TimeInterval(pause))
                        if random.nextDouble() < 0.7 { sender = sender == you ? them : you }
                    }
                }
            }
            day = calendar.date(byAdding: .day, value: 1, to: day) ?? lastDay.addingTimeInterval(86400)
        }
        let notice = language == .italian
            ? "\u{200E}I messaggi e le chiamate sono crittografati end-to-end."
            : "\u{200E}Messages and calls are end-to-end encrypted."
        if let first = lines.first, let bracket = first.firstIndex(of: "]") {
            lines.insert(String(first[...bracket]) + " \(them): " + notice, at: 0)
        }
        return lines.joined(separator: "\r\n") + "\r\n"
    }

    /// Evenings most, then lunch, rarely at night.
    private static func hourOfConversation(_ random: inout SplitMix64) -> Int {
        let roll = random.nextDouble()
        if roll < 0.45 { return 19 + random.next(below: 4) }
        if roll < 0.7 { return 12 + random.next(below: 3) }
        if roll < 0.95 { return 8 + random.next(below: 4) }
        return 23
    }

    /// `[15/10/26, 18:30:12]` in Italian, `[10/15/26, 6:30:12 PM]` in English (US).
    private static func header(_ date: Date, language: Language, calendar: Calendar) -> String {
        let parts = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        let year = (parts.year ?? 2000) % 100
        let minute = twoDigits(parts.minute ?? 0)
        let second = twoDigits(parts.second ?? 0)
        let hour = parts.hour ?? 0
        switch language {
        case .italian:
            return "[\(twoDigits(parts.day ?? 1))/\(twoDigits(parts.month ?? 1))/\(twoDigits(year)), \(twoDigits(hour)):\(minute):\(second)]"
        case .english:
            let twelve = hour % 12 == 0 ? 12 : hour % 12
            return "[\(parts.month ?? 1)/\(parts.day ?? 1)/\(twoDigits(year)), \(twelve):\(minute):\(second)\u{202F}\(hour < 12 ? "AM" : "PM")]"
        }
    }

    private static func twoDigits(_ value: Int) -> String {
        value < 10 ? "0\(value)" : "\(value)"
    }

    private static let italianPhrases = [
        "Ciao! Come va?", "Tutto bene, tu?", "Stasera cena da me?", "Volentieri, porto il vino",
        "Arrivo tra dieci minuti", "Sono in ritardo, scusa", "Hai visto la partita?", "Che giornata lunga",
        "Domani mattina corsa al parco?", "Ok, alle otto", "Buongiorno", "Buonanotte",
        "Mi passi la ricetta della torta?", "Ti chiamo dopo", "Perfetto", "Ahah sì",
        "Che film guardiamo?", "Ho prenotato il ristorante", "Ricordati il pane", "Grazie mille",
        "Sei a casa?", "Esco ora dall'ufficio", "Weekend al mare?", "Piove, rimandiamo",
        "Ho trovato i biglietti per il concerto", "Dove ci vediamo?", "Al solito bar", "Ci sono",
    ]

    private static let englishPhrases = [
        "Hi! How's it going?", "All good, you?", "Dinner at mine tonight?", "Sure, I'll bring wine",
        "Be there in ten", "Running late, sorry", "Did you see the game?", "What a long day",
        "Run in the park tomorrow morning?", "Ok, at eight", "Good morning", "Good night",
        "Can you send me the cake recipe?", "I'll call you later", "Perfect", "Haha yes",
        "What movie are we watching?", "I booked the restaurant", "Remember the bread", "Thanks a lot",
        "Are you home?", "Leaving the office now", "Beach this weekend?", "It's raining, let's postpone",
        "I found tickets for the concert", "Where do we meet?", "The usual café", "I'm in",
    ]
}

/// A tiny seeded generator: the same seed, the same chat.
private nonisolated struct SplitMix64 {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state &+= 0x9E37_79B9_7F4A_7C15
        var value = state
        value = (value ^ (value >> 30)) &* 0xBF58_476D_1CE4_E5B9
        value = (value ^ (value >> 27)) &* 0x94D0_49BB_1331_11EB
        return value ^ (value >> 31)
    }

    mutating func next(below bound: Int) -> Int {
        Int(next() % UInt64(bound))
    }

    mutating func nextDouble() -> Double {
        Double(next() >> 11) / Double(1 << 53)
    }
}
