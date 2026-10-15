import Testing
@testable import SbuChats

struct WhatsAppLineScannerTests {
    nonisolated struct Case: Sendable, CustomTestStringConvertible {
        let line: String
        let style: MessageHeader.Style
        let fields: [Int]
        let time: [Int]
        let meridiem: MessageHeader.Meridiem?
        let sender: String?
        let body: String

        var testDescription: String { line }
    }

    nonisolated static let headers: [Case] = [
        Case(line: "[15/10/26, 18:30:12] Anna: Ciao", style: .bracketed, fields: [15, 10, 26], time: [18, 30, 12], meridiem: nil, sender: "Anna", body: "Ciao"),
        Case(line: "\u{200E}[15/10/26, 18:30:12] Anna Rossi: \u{200E}immagine omessa", style: .bracketed, fields: [15, 10, 26], time: [18, 30, 12],
             meridiem: nil, sender: "Anna Rossi", body: "\u{200E}immagine omessa"),
        Case(line: "[3/12/24, 9:41:07\u{202F}PM] Sam: Hey: you", style: .bracketed, fields: [3, 12, 24], time: [9, 41, 7], meridiem: .pm, sender: "Sam", body: "Hey: you"),
        Case(line: "[2024-03-12, 21:41:07] Sam: Hi", style: .bracketed, fields: [2024, 3, 12], time: [21, 41, 7], meridiem: nil, sender: "Sam", body: "Hi"),
        Case(line: "05/01/25, 10:01 - Marta: Buon anno!", style: .dashed, fields: [5, 1, 25], time: [10, 1, 0], meridiem: nil, sender: "Marta", body: "Buon anno!"),
        Case(line: "1/5/25, 9:41 PM - Chris: Did you?", style: .dashed, fields: [1, 5, 25], time: [9, 41, 0], meridiem: .pm, sender: "Chris", body: "Did you?"),
        Case(line: "5/1/25 9:41 p. m. - Lucía: Hola", style: .dashed, fields: [5, 1, 25], time: [9, 41, 0], meridiem: .pm, sender: "Lucía", body: "Hola"),
        Case(line: "15.10.26, 18:30 - Jörg: Hallo", style: .dashed, fields: [15, 10, 26], time: [18, 30, 0], meridiem: nil, sender: "Jörg", body: "Hallo"),
        Case(line: "05/01/2025 10:00 - Messages and calls are end-to-end encrypted.", style: .dashed, fields: [5, 1, 2025], time: [10, 0, 0],
             meridiem: nil, sender: nil, body: "Messages and calls are end-to-end encrypted."),
        Case(line: "[15/10/26, 18:30:12] ~\u{202F}Gio: Ciao", style: .bracketed, fields: [15, 10, 26], time: [18, 30, 12], meridiem: nil, sender: "~\u{202F}Gio", body: "Ciao"),
    ]

    @Test(arguments: headers)
    func readsHeaders(_ testCase: Case) throws {
        let header = try #require(WhatsAppLineScanner.header(of: testCase.line))
        #expect(header.style == testCase.style)
        #expect(header.dateFields == testCase.fields)
        #expect([header.hour, header.minute, header.second] == testCase.time)
        #expect(header.meridiem == testCase.meridiem)
        #expect(header.sender == testCase.sender)
        #expect(header.body == testCase.body)
    }

    @Test(arguments: [
        "anzi, porta anche il pane",
        "",
        "12 mele e 3 pere",
        "Ci vediamo il 15/10/26 alle 18:30",
        "15/10/26 senza ora",
        "[15/10/26, 25:30:12] Anna: ora impossibile",
        "15/10/26, 18:30 Anna: manca il trattino",
        "123/10/26, 18:30 - Anna: troppe cifre",
    ])
    func treatsOtherLinesAsContinuations(line: String) {
        #expect(WhatsAppLineScanner.header(of: line) == nil)
    }
}
