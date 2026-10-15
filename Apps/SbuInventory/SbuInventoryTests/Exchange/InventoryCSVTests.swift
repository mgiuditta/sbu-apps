import Foundation
import Testing
@testable import SbuInventory

struct InventoryCSVTests {
    private let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Europe/Rome")!
        return calendar
    }()

    private var serial: FieldColumn { FieldColumn(name: "Numero di serie", kind: .text) }
    private var warranty: FieldColumn { FieldColumn(name: "Garanzia fino al", kind: .date) }

    private var rows: [InventoryRow] {
        var folder = InventoryRow()
        folder.kind = .folder
        folder.name = "Scatola 3"
        folder.path = ["Casa", "Garage"]
        folder.code = "8001234567890"

        var drill = InventoryRow()
        drill.id = UUID(uuidString: "6F1C2B4E-1111-4A53-9A1E-AD316AF563D6")
        drill.name = "Trapano, \"a percussione\""
        drill.quantity = 2
        drill.minimumQuantity = 1
        drill.path = ["Casa", "Garage", "Scatola 3"]
        drill.unitPrice = Decimal(string: "89.90")
        drill.currency = "EUR"
        drill.purchaseDate = calendar.date(from: DateComponents(year: 2024, month: 3, day: 31, hour: 12))
        drill.tags = ["attrezzi", "elettrico"]
        drill.code = "QR-42"
        drill.notes = "Prima riga\nseconda riga; con punto e virgola"
        drill.photos = ["photos/a.heic", "photos/b.heic"]
        drill.fields = [CustomFieldCell(column: serial, value: "SN 001"), CustomFieldCell(column: warranty, value: "2026-03-31")]

        var glasses = InventoryRow()
        glasses.id = UUID(uuidString: "6F1C2B4E-2222-4A53-9A1E-AD316AF563D6")
        glasses.name = "Bicchieri"
        glasses.quantity = 12
        return [folder, drill, glasses]
    }

    @Test func roundTripKeepsEveryValue() throws {
        let text = InventoryCSV.text(rows, fields: [serial, warranty], calendar: calendar)
        let read = try InventoryCSV.rows(text, calendar: calendar)
        #expect(read.count == 3)
        #expect(read[0].kind == .folder)
        #expect(read[0].path == ["Casa", "Garage"])
        #expect(read[0].code == "8001234567890")
        #expect(read[1] == rows[1])
        #expect(read[2].name == "Bicchieri")
        #expect(read[2].quantity == 12)
        #expect(read[2].unitPrice == nil)
        #expect(read[2].fields.isEmpty)
    }

    @Test func fileStartsWithAByteOrderMarkAndTheHeader() {
        let text = InventoryCSV.text([], fields: [warranty], calendar: calendar)
        #expect(text.hasPrefix("\u{FEFF}tipo,id,nome,quantita,quantita_minima,percorso,prezzo_unitario,valuta,data_acquisto,tag,etichetta,note,foto,campo:date:Garanzia fino al\n"))
    }

    @Test func spreadsheetFileWithSemicolonsAndEnglishHeadersReads() throws {
        let text = "Name;Quantity;Location;Price;Purchase date;Tags\nDrill;3;Home > Garage;\"1.234,50\";31/12/2023;tools, power\n;5;;;;\n"
        let read = try InventoryCSV.rows(text, calendar: calendar)
        #expect(read.count == 1)
        #expect(read[0].name == "Drill")
        #expect(read[0].quantity == 3)
        #expect(read[0].path == ["Home", "Garage"])
        #expect(read[0].unitPrice == Decimal(string: "1234.5"))
        #expect(read[0].tags == ["tools", "power"])
        #expect(read[0].purchaseDate.map { calendar.component(.year, from: $0) } == 2023)
        #expect(read[0].kind == .item)
        #expect(read[0].id == nil)
    }

    @Test func fileWithoutANameColumnFails() {
        #expect(throws: InventoryCSV.Failure.noNameColumn) {
            try InventoryCSV.rows("quantita,prezzo\n1,2\n", calendar: calendar)
        }
        #expect(throws: InventoryCSV.Failure.empty) {
            try InventoryCSV.rows("", calendar: calendar)
        }
    }

    @Test(arguments: [
        ("12.50", "12.5"),
        ("12,50", "12.5"),
        ("€ 1.234,56", "1234.56"),
        ("$1,234.56", "1234.56"),
        ("1,234", "1234"),
        ("-3", "-3"),
        ("abc", nil),
    ] as [(String, String?)])
    func decimalsReadInEveryCommonForm(text: String, expected: String?) {
        #expect(CSVValue.decimal(text) == expected.flatMap { Decimal(string: $0) })
    }

    @Test func daysWriteAsIsoAndReadBack() {
        let date = calendar.date(from: DateComponents(year: 2025, month: 1, day: 5, hour: 23, minute: 30))!
        #expect(CSVValue.day(date, calendar: calendar) == "2025-01-05")
        #expect(CSVValue.date("2025-01-05", calendar: calendar).map { CSVValue.day($0, calendar: calendar) } == "2025-01-05")
        #expect(CSVValue.date("05.01.2025", calendar: calendar).map { CSVValue.day($0, calendar: calendar) } == "2025-01-05")
        #expect(CSVValue.date("2025-13-40", calendar: calendar) == nil)
    }

    @Test func fieldColumnHeaderNamesKindAndName() {
        #expect(FieldColumn(name: "Garanzia: fino al", kind: .date).header == "campo:date:Garanzia: fino al")
        #expect(FieldColumn(header: "campo:date:Garanzia: fino al") == FieldColumn(name: "Garanzia: fino al", kind: .date))
        #expect(FieldColumn(header: "Campo: Colore") == FieldColumn(name: "Colore", kind: .text))
        #expect(FieldColumn(header: "nome") == nil)
        #expect(FieldColumn(header: "campo:") == nil)
    }
}
