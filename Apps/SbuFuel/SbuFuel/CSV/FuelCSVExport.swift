import CoreTransferable
import Foundation
import UniformTypeIdentifiers

/// A vehicle's fuel-ups and services as one CSV file: your log, readable by any spreadsheet and by
/// this app's import. Numbers use a dot and no grouping; dates are yyyy-MM-dd; the odometer is in
/// the vehicle's unit, quantities in litres, amounts in the currency of each entry.
nonisolated struct FuelCSVExport: Transferable, Sendable {
    static let header = ["tipo", "data", "contachilometri", "unita", "litri", "importo", "valuta", "pieno", "saltato", "distributore", "intervento", "note"]
    static let fuelType = "rifornimento"
    static let serviceType = "intervento"

    struct Fuel: Sendable {
        var record: FillRecord
        var currencyCode: String
        var station: String
        var note: String
    }

    struct Service: Sendable {
        var title: String
        var date: Date
        var odometerKm: Double?
        var cost: Decimal
        var currencyCode: String
        var note: String
    }

    let text: String
    let fileName: String

    init(vehicleName: String, unit: DistanceUnit, fuel: [Fuel], services: [Service], date: Date = .now, calendar: Calendar = .current) {
        let fuelRows = fuel.map { entry in
            (entry.record.date, entry.record.odometerKm, [
                Self.fuelType,
                Self.day(entry.record.date, calendar: calendar),
                Self.number(unit.value(fromKm: entry.record.odometerKm), digits: 0...1),
                unit.symbol,
                Self.number(entry.record.litres, digits: 0...3),
                "\(entry.record.totalPrice)",
                entry.currencyCode,
                entry.record.isFull ? "si" : "no",
                entry.record.missedPrevious ? "si" : "no",
                entry.station,
                "",
                entry.note,
            ])
        }
        let serviceRows = services.map { entry in
            (entry.date, entry.odometerKm ?? 0, [
                Self.serviceType,
                Self.day(entry.date, calendar: calendar),
                entry.odometerKm.map { Self.number(unit.value(fromKm: $0), digits: 0...1) } ?? "",
                unit.symbol,
                "",
                "\(entry.cost)",
                entry.currencyCode,
                "",
                "",
                "",
                entry.title,
                entry.note,
            ])
        }
        let rows = (fuelRows + serviceRows).sorted { ($0.0, $0.1) < ($1.0, $1.1) }.map { CSVTable.line($0.2) }
        text = "\u{FEFF}" + ([CSVTable.line(Self.header)] + rows).joined(separator: "\n") + "\n"
        let slug = vehicleName.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: nil)
            .lowercased().map { $0.isLetter || $0.isNumber ? String($0) : "-" }.joined()
            .split(separator: "-").joined(separator: "-")
        fileName = "sbu-fuel-\(slug.isEmpty ? "veicolo" : slug)-\(Self.day(date, calendar: calendar)).csv"
    }

    /// yyyy-MM-dd in the calendar's time zone: a day, never an instant that could shift.
    static func day(_ date: Date, calendar: Calendar) -> String {
        let parts = calendar.dateComponents([.year, .month, .day], from: date)
        return String(parts.year ?? 0) + "-" + twoDigits(parts.month ?? 0) + "-" + twoDigits(parts.day ?? 0)
    }

    private static func twoDigits(_ number: Int) -> String {
        number < 10 ? "0\(number)" : "\(number)"
    }

    private static func number(_ value: Double, digits: ClosedRange<Int>) -> String {
        value.formatted(.number.precision(.fractionLength(digits)).grouping(.never).locale(Locale(identifier: "en_US_POSIX")))
    }

    static var transferRepresentation: some TransferRepresentation {
        FileRepresentation(exportedContentType: .commaSeparatedText) { export in
            let url = URL.temporaryDirectory.appending(path: export.fileName)
            try Data(export.text.utf8).write(to: url, options: .atomic)
            return SentTransferredFile(url)
        }
    }
}
