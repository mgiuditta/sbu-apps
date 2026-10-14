import Foundation
import Testing
@testable import SbuScanner

struct HistoryCSVTests {
    @Test func quotesFieldsWithCommasQuotesAndNewlines() {
        let row = HistoryCSV.Row(date: Date(timeIntervalSince1970: 0), kind: "Testo", symbology: "QR", folder: "Lavoro, casa", isFavorite: true, content: "Disse \"ciao\"\nA presto")
        let csv = HistoryCSV.make([row], header: ["Data", "Tipo", "Codice", "Cartella", "Preferito", "Contenuto"])
        #expect(csv == "Data,Tipo,Codice,Cartella,Preferito,Contenuto\r\n1970-01-01T00:00:00Z,Testo,QR,\"Lavoro, casa\",1,\"Disse \"\"ciao\"\"\nA presto\"\r\n")
    }

    @Test(arguments: ["=HYPERLINK(\"http://x\")", "+1+1", "-2", "@SUM(A1)", "\tcmd", "\r\n=1+1", "  =1+1", "\u{00A0}=1+1", "\u{3000}=1", "＝1+1", "|cmd", "\u{0}=1"])
    func formulasStayText(content: String) {
        let row = HistoryCSV.Row(date: Date(timeIntervalSince1970: 0), kind: "Testo", symbology: "QR", folder: "", isFavorite: false, content: content)
        let csv = HistoryCSV.make([row], header: [])
        // The content is the last cell: it starts with an apostrophe, quoted or not.
        #expect(csv.hasSuffix(",'" + content + "\r\n") || csv.hasSuffix(",\"'" + content.replacing("\"", with: "\"\"") + "\"\r\n"), "\(csv)")
    }

    @Test(arguments: ["https://sbu.dev", "Ciao", "4006381333931", "WIFI:S:Casa;;"])
    func ordinaryContentIsLeftAlone(content: String) {
        let row = HistoryCSV.Row(date: Date(timeIntervalSince1970: 0), kind: "Testo", symbology: "QR", folder: "", isFavorite: false, content: content)
        #expect(HistoryCSV.make([row], header: []).hasSuffix("," + content + "\r\n"))
    }
}
