import Foundation
import SwiftData
import Testing
@testable import SbuSubscriptions

struct CSVImportTests {
    let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Europe/Rome")!
        return calendar
    }()

    func day(_ year: Int, _ month: Int, _ day: Int) -> Date {
        calendar.date(from: DateComponents(year: year, month: month, day: day))!
    }

    func read(_ text: String, locale: String = "it_IT") throws -> [CSVImport.Candidate] {
        let file = try CSVImport(text: text, mainCurrency: "EUR", today: day(2026, 10, 14), locale: Locale(identifier: locale), calendar: calendar)
        return file.rows.compactMap { try? $0.result.get() }
    }

    @Test func readsTheExportOfThePreviousVersion() throws {
        // As the 1.0 wrote it: BOM, Italian headers, toFixed(2), toISOString() in UTC, si/no.
        let text = "\u{FEFF}nome,importo,valuta,ciclo_fatturazione,prossimo_rinnovo,categoria,in_prova,fine_prova,note\n"
            + "Netflix,12.99,EUR,monthly,2026-06-14T22:00:00.000Z,Streaming,no,,\"Piano famiglia, 4 schermi\"\n"
            + "Palestra,120.00,CHF,quarterly,2026-10-31T23:00:00.000Z,Fitness,si,2026-10-31T23:00:00.000Z,"
        let rows = try read(text)
        #expect(rows.count == 2)
        #expect(rows[0] == CSVImport.Candidate(name: "Netflix", price: Decimal(string: "12.99")!, currencyCode: "EUR", cycle: .monthly,
                                               date: day(2026, 6, 15), trialEnd: nil, category: "Streaming", notes: "Piano famiglia, 4 schermi",
                                               status: .active, reminderDaysBefore: 1, list: nil, paymentMethod: "", website: nil))
        #expect(rows[1].cycle == .every(3, .month))
        #expect(rows[1].trialEnd == day(2026, 11, 1))
    }

    @Test func readsAnItalianSpreadsheet() throws {
        let text = "Servizio;Prezzo;Frequenza;Prossimo pagamento\r\nSpotify;10,99 €;Mensile;17/10/2026\r\nArchivio;1.234,56;Annuale;01/02/2027\r\n"
        let rows = try read(text)
        #expect(rows.map(\.name) == ["Spotify", "Archivio"])
        #expect(rows.map(\.price) == [Decimal(string: "10.99")!, Decimal(string: "1234.56")!])
        #expect(rows.map(\.date) == [day(2026, 10, 17), day(2027, 2, 1)])
        #expect(rows.allSatisfy { $0.currencyCode == "EUR" }, "No currency column: the main currency")
    }

    @Test func readsAnEnglishSheetMonthFirst() throws {
        let text = "Name,Price,Currency,Billing Cycle,Next Payment\nDesign tools,\"$1,200.00\",USD,every 2 weeks,10/17/2026\n"
        let row = try #require(try read(text, locale: "en_US").first)
        #expect(row.price == 1200)
        #expect(row.cycle == .every(2, .week))
        #expect(row.date == day(2026, 10, 17))
    }

    @Test func badRowsSayWhyAndTheRestArrive() throws {
        let text = "nome,importo,ciclo_fatturazione,prossimo_rinnovo\n,5,monthly,2026-11-01\nA,gratis,monthly,2026-11-01\nB,5,fortnightly,2026-11-01\nC,5,monthly,ieri\nD,5,monthly,2026-11-01\n"
        let file = try CSVImport(text: text, mainCurrency: "EUR", today: .now, locale: Locale(identifier: "it_IT"), calendar: calendar)
        let problems = file.rows.compactMap { row -> CSVImport.Problem? in
            if case let .failure(problem) = row.result { return problem }
            return nil
        }
        #expect(problems == [.noName, .badPrice("gratis"), .badCycle("fortnightly"), .badDate("ieri")])
        #expect(file.rows.map(\.line) == [2, 3, 4, 5, 6])
    }

    @Test func fileWithoutNameOrPriceIsRefused() {
        #expect(throws: CSVImport.Failure.unknownColumns) {
            try CSVImport(text: "a,b\n1,2\n", mainCurrency: "EUR", today: .now, locale: .current, calendar: calendar)
        }
        #expect(throws: CSVImport.Failure.empty) {
            try CSVImport(text: "nome,importo\n", mainCurrency: "EUR", today: .now, locale: .current, calendar: calendar)
        }
    }

    @Test func exportReadsBackTheSame() throws {
        let context = ModelContext(try ModelContainer.subscriptions(inMemory: true))
        try CategorySeeder.seed(context)
        let music = Subscription(name: "Musica \"HiFi\"", price: Decimal(string: "10.99")!, currencyCode: "USD", startDate: day(2026, 1, 20), cycle: .every(2, .week))
        music.notes = "riga uno\nriga due"
        music.status = .paused
        music.reminderDaysBefore = nil
        music.url = URL(string: "https://example.com")
        context.insert(music)

        let export = CSVExport([music], date: day(2026, 10, 14), calendar: calendar)
        #expect(export.fileName == "sbu-subscriptions-2026-10-14.csv")
        let row = try #require(try read(export.text).first)
        #expect(row.name == "Musica \"HiFi\"")
        #expect(row.price == Decimal(string: "10.99"))
        #expect(row.currencyCode == "USD")
        #expect(row.cycle == .every(2, .week))
        #expect(row.date == music.schedule.nextPayment(onOrAfter: day(2026, 10, 14), in: calendar))
        #expect(row.notes == "riga uno\nriga due")
        #expect(row.status == .paused)
        #expect(row.reminderDaysBefore == nil)
        #expect(row.website == URL(string: "https://example.com"))
    }

    @Test(arguments: [("12,99", "12.99"), ("12.99", "12.99"), ("€ 9,99", "9.99"), ("1.234", "1234"), ("1,5", "1.5"), ("1.234,56", "1234.56"), ("1,234.56", "1234.56"), ("100", "100")])
    func prices(text: String, expected: String) {
        #expect(CSVValue.price(text) == Decimal(string: expected))
    }

    @Test(arguments: [("Mensile", BillingCycle.monthly), ("annual", .yearly), ("ogni 3 mesi", .every(3, .month)), ("2 week", .every(2, .week)), ("una tantum", .once), ("Trimestrale", .every(3, .month))])
    func cycles(text: String, expected: BillingCycle) {
        #expect(CSVValue.cycle(text) == expected)
    }
}
