import Foundation
import Testing
@testable import SbuFuel

struct CSVImportTests {
    private let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Europe/Rome")!
        return calendar
    }()

    private func date(_ year: Int, _ month: Int, _ day: Int) -> Date {
        calendar.date(from: DateComponents(year: year, month: month, day: day, hour: 12))!
    }

    @Test func exportReadsBackTheSameLog() throws {
        let fills = [
            FuelCSVExport.Fuel(record: FillRecord(date: date(2026, 3, 1), odometerKm: 45_210, litres: 38.42, totalPrice: Decimal(string: "68.77")!),
                               currencyCode: "EUR", station: "Q8, via Roma", note: "con \"virgolette\""),
            FuelCSVExport.Fuel(record: FillRecord(date: date(2026, 3, 9), odometerKm: 45_480, litres: 12, isFull: false, totalPrice: 0),
                               currencyCode: "EUR", station: "", note: ""),
            FuelCSVExport.Fuel(record: FillRecord(date: date(2026, 3, 20), odometerKm: 45_830, litres: 30.5, missedPrevious: true, totalPrice: 55),
                               currencyCode: "EUR", station: "", note: ""),
        ]
        let services = [FuelCSVExport.Service(title: "Cambio olio", date: date(2026, 3, 5), odometerKm: 45_300, cost: 89, currencyCode: "EUR", note: "")]
        let export = FuelCSVExport(vehicleName: "Panda Città", unit: .kilometres, fuel: fills, services: services, date: date(2026, 4, 1), calendar: calendar)
        #expect(export.fileName == "sbu-fuel-panda-citta-2026-04-01.csv")

        let importer = try #require(CSVImporter(text: export.text))
        let mapping = ImportField.guess(importer.header)
        // Every column but the unit and the currency, which the import sheet asks for instead.
        #expect(mapping.count == 10)
        let result = importer.entries(mapping: mapping, options: .init(distanceUnit: .kilometres, volumeUnit: .litres, dateOrder: .yearMonthDay),
                                      existing: [], calendar: calendar)
        #expect(result.unreadable == 0)
        #expect(result.entries.count == 4)
        let fuel = result.entries.compactMap { entry -> (FillRecord, String, String)? in
            if case let .fuel(record, station, note) = entry { return (record, station, note) }
            return nil
        }
        #expect(fuel.map(\.0.odometerKm) == [45_210, 45_480, 45_830])
        #expect(fuel.map(\.0.litres) == [38.42, 12, 30.5])
        #expect(fuel.map(\.0.totalPrice) == [Decimal(string: "68.77")!, 0, 55])
        #expect(fuel.map(\.0.isFull) == [true, false, true])
        #expect(fuel.map(\.0.missedPrevious) == [false, false, true])
        #expect(fuel[0].1 == "Q8, via Roma")
        #expect(fuel[0].2 == "con \"virgolette\"")
        #expect(calendar.isDate(fuel[2].0.date, inSameDayAs: date(2026, 3, 20)))
        #expect(result.entries.contains(.service(title: "Cambio olio", date: date(2026, 3, 5), odometerKm: 45_300, cost: 89, note: "")))
    }

    @Test func theSameFileTwiceAddsNothing() throws {
        let text = "data,contachilometri,litri,importo\n2026-03-01,45210,38.4,68.70\n2026-03-01,45210,38.4,68.70\n2026-03-15,45700,30,55\n"
        let importer = try #require(CSVImporter(text: text))
        let options = CSVImporter.Options(distanceUnit: .kilometres, volumeUnit: .litres, dateOrder: .yearMonthDay)
        let mapping = ImportField.guess(importer.header)
        let first = importer.entries(mapping: mapping, options: options, existing: [], calendar: calendar)
        #expect(first.entries.count == 2)
        #expect(first.duplicates == 1)
        let again = importer.entries(mapping: mapping, options: options, existing: first.entries, calendar: calendar)
        #expect(again.entries.isEmpty)
        #expect(again.duplicates == 3)
    }

    @Test func anAmericanExportInGallonsAndMilesWithPricePerGallon() throws {
        let text = """
        car_name,odometer,gallons,price,fuelup_date,partial_fuelup,missed_fuelup,notes
        Civic,"12,300",10.5,3.299,03/14/2026,0,0,
        Civic,"12,600",4,3.199,03/20/2026,1,0,top up
        """
        let importer = try #require(CSVImporter(text: text))
        let mapping = ImportField.guess(importer.header)
        #expect(mapping[.unitPrice] == 3)
        #expect(mapping[.partial] == 5)
        let dates = importer.rows.map { CSVImporter.cell(.date, in: $0, mapping: mapping) }
        #expect(DateOrder.detect(dates, locale: Locale(identifier: "en_US")) == .monthDayYear)
        let result = importer.entries(mapping: mapping, options: .init(distanceUnit: .miles, volumeUnit: .usGallons, dateOrder: .monthDayYear),
                                      existing: [], calendar: calendar)
        #expect(result.entries.count == 2)
        guard case let .fuel(first, _, _) = result.entries[0], case let .fuel(second, _, note) = result.entries[1] else {
            Issue.record("Expected two fuel-ups")
            return
        }
        #expect(abs(first.odometerKm - DistanceUnit.miles.km(from: 12_300)) < 0.001)
        #expect(abs(first.litres - VolumeUnit.usGallons.litres(from: 10.5)) < 0.001)
        #expect(first.totalPrice == Decimal(string: "34.64"))
        #expect(first.isFull)
        #expect(!second.isFull)
        #expect(note == "top up")
        #expect(calendar.isDate(first.date, inSameDayAs: date(2026, 3, 14)))
    }

    @Test func anItalianSpreadsheetWithSemicolonsAndCommas() throws {
        let text = "Data;Km;Litri;Totale;Pieno\n14/03/2026;45.210;38,40;68,70 €;sì\n02/04/2026;45.700;30;55;no\n"
        let importer = try #require(CSVImporter(text: text))
        let mapping = ImportField.guess(importer.header)
        let result = importer.entries(mapping: mapping, options: .init(distanceUnit: .kilometres, volumeUnit: .litres, dateOrder: .dayMonthYear),
                                      existing: [], calendar: calendar)
        guard case let .fuel(first, _, _) = result.entries.first, case let .fuel(second, _, _) = result.entries.last else {
            Issue.record("Expected fuel-ups")
            return
        }
        #expect(first.odometerKm == 45_210)
        #expect(first.litres == 38.4)
        #expect(first.totalPrice == Decimal(string: "68.70"))
        #expect(first.isFull)
        #expect(!second.isFull)
        #expect(calendar.isDate(second.date, inSameDayAs: date(2026, 4, 2)))
    }

    @Test func rowsWithoutWhatAFuelUpNeedsAreCounted() throws {
        let text = "data,contachilometri,litri\n2026-03-01,,30\nnot a date,45000,30\n2026-03-02,45000,\n2026-03-03,45200,20\n"
        let importer = try #require(CSVImporter(text: text))
        let result = importer.entries(mapping: ImportField.guess(importer.header),
                                      options: .init(distanceUnit: .kilometres, volumeUnit: .litres, dateOrder: .yearMonthDay),
                                      existing: [], calendar: calendar)
        #expect(result.entries.count == 1)
        #expect(result.unreadable == 3)
    }

    @Test(arguments: [
        (["date", "odometer", "gallons"], nil as DistanceUnit?, VolumeUnit.usGallons as VolumeUnit?),
        (["date", "mileage", "uk_gallons"], .miles, .imperialGallons),
        (["data", "km", "litri"], .kilometres, .litres),
        (["data", "contachilometri", "quantità"], nil, nil),
    ])
    func headersNameTheirUnits(header: [String], distance: DistanceUnit?, volume: VolumeUnit?) {
        let units = ImportField.units(header, mapping: ImportField.guess(header))
        #expect(units.distance == distance)
        #expect(units.volume == volume)
    }

    @Test func aHeaderAloneIsNoFile() {
        #expect(CSVImporter(text: "data,litri\n") == nil)
        #expect(CSVImporter(text: "") == nil)
    }

    @Test(arguments: [
        ("42,5", "42.5"),
        ("42.5", "42.5"),
        ("1.234,56 €", "1234.56"),
        ("$1,234.56", "1234.56"),
        ("1,234,567", "1234567"),
        ("1.234.567", "1234567"),
        ("€ 0", "0"),
    ])
    func numbersFromAnySpreadsheet(text: String, expected: String) {
        #expect(CSVValue.decimal(text) == Decimal(string: expected))
    }

    @Test(arguments: [("45.210", 45_210.0), ("45,210", 45_210.0), ("45210,5", 45_210.5), ("12 300 km", 12_300.0)])
    func odometerReadingsGroupThousands(text: String, expected: Double) {
        #expect(CSVValue.double(text, isReading: true) == expected)
    }

    @Test(arguments: [
        ("2026-03-14", DateOrder.dayMonthYear, 2026, 3, 14),
        ("14/03/2026", .dayMonthYear, 2026, 3, 14),
        ("3/14/26 08:30", .monthDayYear, 2026, 3, 14),
        ("14.03.2026", .dayMonthYear, 2026, 3, 14),
        ("2026-03-14 00:00:00", .monthDayYear, 2026, 3, 14),
    ])
    func datesInEveryOrder(text: String, order: DateOrder, year: Int, month: Int, day: Int) throws {
        let parsed = try #require(order.date(from: text, calendar: calendar))
        #expect(calendar.dateComponents([.year, .month, .day], from: parsed) == DateComponents(year: year, month: month, day: day))
    }

    @Test(arguments: ["31/02/2026", "13/13/2026", "", "ieri"])
    func impossibleDatesAreRejected(text: String) {
        #expect(DateOrder.dayMonthYear.date(from: text, calendar: calendar) == nil)
    }

    @Test(arguments: [
        (["14/03/2026", "01/04/2026"], "it_IT", DateOrder.dayMonthYear),
        (["03/14/2026"], "it_IT", .monthDayYear),
        (["2026-03-14"], "en_US", .yearMonthDay),
        (["01/02/2026"], "en_US", .monthDayYear),
        (["01/02/2026"], "it_IT", .dayMonthYear),
    ])
    func dateOrderIsDetected(samples: [String], identifier: String, expected: DateOrder) {
        #expect(DateOrder.detect(samples, locale: Locale(identifier: identifier)) == expected)
    }

    @Test(arguments: ["si", "Sì", "yes", "TRUE", "1", "x"])
    func flagsSayYes(text: String) {
        #expect(CSVValue.flag(text))
    }

    @Test(arguments: ["no", "0", "", "false"])
    func flagsSayNo(text: String) {
        #expect(!CSVValue.flag(text))
    }
}
