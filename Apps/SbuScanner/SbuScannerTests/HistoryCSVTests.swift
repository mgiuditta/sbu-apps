import Foundation
import Testing
@testable import SbuScanner

struct HistoryCSVTests {
    @Test func quotesFieldsWithCommasQuotesAndNewlines() {
        let row = HistoryCSV.Row(date: Date(timeIntervalSince1970: 0), kind: "Testo", symbology: "QR", folder: "Lavoro, casa", isFavorite: true, content: "Disse \"ciao\"\nA presto")
        let csv = HistoryCSV.make([row], header: ["Data", "Tipo", "Codice", "Cartella", "Preferito", "Contenuto"])
        #expect(csv == "Data,Tipo,Codice,Cartella,Preferito,Contenuto\r\n1970-01-01T00:00:00Z,Testo,QR,\"Lavoro, casa\",1,\"Disse \"\"ciao\"\"\nA presto\"\r\n")
    }

    @Test(arguments: ["=HYPERLINK(\"http://x\")", "+1+1", "-2", "@SUM(A1)", "\tcmd"])
    func formulasStayText(content: String) {
        let row = HistoryCSV.Row(date: Date(timeIntervalSince1970: 0), kind: "Testo", symbology: "QR", folder: "", isFavorite: false, content: content)
        let line = HistoryCSV.make([row], header: []).split(separator: "\r\n").last.map(String.init) ?? ""
        #expect(line.hasSuffix(",'" + content) || line.hasSuffix(",\"'" + content.replacing("\"", with: "\"\"") + "\""), "\(line)")
    }
}
