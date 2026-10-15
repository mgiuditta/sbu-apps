import Testing
@testable import SbuChats

struct MessageClassifierTests {
    @Test(arguments: [
        ("Ciao, come va?", MessageKind.text),
        ("\u{200E}immagine omessa", .omittedMedia),
        ("\u{200E}image omitted", .omittedMedia),
        ("\u{200E}imagen omitida", .omittedMedia),
        ("\u{200E}Bild weggelassen", .omittedMedia),
        ("\u{200E}vidéo absente", .omittedMedia),
        ("\u{200E}figurinha omitida", .omittedMedia),
        ("video omesso", .omittedMedia),
        ("<Media omitted>", .omittedMedia),
        ("<Media omessi>", .omittedMedia),
        ("<Multimedia omitido>", .omittedMedia),
        ("<Medien ausgeschlossen>", .omittedMedia),
        ("<Mídia oculta>", .omittedMedia),
        ("\u{200E}<attached: 00000012-PHOTO-2024-03-13-12-30-00.jpg>", .media),
        ("\u{200E}<allegato: 00000013-AUDIO-2024-03-13-12-30-00.opus>", .media),
        ("IMG-20250113-WA0001.jpg (file allegato)", .media),
        ("PTT-20250113-WA0002.opus (file attached)\nascolta", .media),
        ("Questo messaggio è stato eliminato", .deleted),
        ("\u{200E}This message was deleted.", .deleted),
        ("Hai eliminato questo messaggio.", .deleted),
        ("\u{200E}Chiamata vocale persa", .system),
        ("\u{200E}Messages and calls are end-to-end encrypted.", .system),
        ("ho visto (il film) ieri", .text),
        ("<3 ti voglio bene>", .text),
    ])
    func classifies(body: String, expected: MessageKind) {
        #expect(MessageClassifier.classify(sender: "Anna", body: body).kind == expected)
    }

    @Test func aLineWithoutAuthorIsSystem() {
        #expect(MessageClassifier.classify(sender: nil, body: "Marta ha creato il gruppo").kind == .system)
    }

    @Test(arguments: [
        ("Buongiorno ☀️ \u{200E}<Questo messaggio è stato modificato>", "Buongiorno ☀️"),
        ("See you <This message was edited>", "See you"),
        ("\u{200E}Ciao\u{200E}", "Ciao"),
    ])
    func removesWhatsAppMarkers(body: String, text: String) {
        #expect(MessageClassifier.classify(sender: "Anna", body: body).text == text)
    }

    @Test(arguments: [("Ciao, come va?", 3), ("  ", 0), ("👍 ok", 1), ("a - b", 2), ("riga uno\nriga due", 4)])
    func countsWords(text: String, count: Int) {
        #expect(MessageClassifier.wordCount(text) == count)
    }
}
