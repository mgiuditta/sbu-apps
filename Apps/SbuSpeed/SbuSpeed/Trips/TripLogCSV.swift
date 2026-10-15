import CoreTransferable
import Foundation
import UniformTypeIdentifiers

/// The saved trips as a CSV file, for Esporta CSV: one row per trip, newest first, in the unit
/// on screen. Numbers with a point and times in ISO 8601, so every spreadsheet reads them the same.
nonisolated struct TripLogCSV: Transferable {
    let trips: [TripRecord]
    let unit: SpeedUnit
    /// The day of the export, in the file name.
    let date: Date
    /// The language of the header row.
    var locale: Locale = .autoupdatingCurrent

    /// "Sbu Speed 2026-10-15.csv": the date sorts and reads the same in every language.
    var fileName: String {
        let day = date.formatted(Date.ISO8601FormatStyle(timeZone: .current).year().month().day())
        return "Sbu Speed \(day).csv"
    }

    var header: [String] {
        let speed = unit.symbol
        let length = unit.length.symbol
        return [
            String(localized: "Inizio", locale: locale),
            String(localized: "Fine", locale: locale),
            String(localized: "Durata (s)", locale: locale),
            String(localized: "Distanza (\(length))", locale: locale),
            String(localized: "Massima (\(speed))", locale: locale),
            String(localized: "Media (\(speed))", locale: locale),
        ]
    }

    /// The whole file, lines ended by CRLF as RFC 4180 asks.
    var text: String {
        ([header] + trips.map(row)).map { $0.map(Self.escaped).joined(separator: ",") }.joined(separator: "\r\n") + "\r\n"
    }

    private func row(_ trip: TripRecord) -> [String] {
        let time = Date.ISO8601FormatStyle(timeZone: .current)
        let distance = Measurement(value: trip.distance, unit: UnitLength.meters).converted(to: unit.length).value
        return [
            trip.startedAt.formatted(time),
            trip.endedAt.formatted(time),
            String(Int(trip.movingTime)),
            Self.number(distance, decimals: 2),
            Self.number(unit.value(ofMetersPerSecond: trip.maxSpeed), decimals: 1),
            Self.number(unit.value(ofMetersPerSecond: trip.averageSpeed), decimals: 1),
        ]
    }

    private static func number(_ value: Double, decimals: Int) -> String {
        value.formatted(.number.precision(.fractionLength(decimals)).grouping(.never).locale(Locale(identifier: "en_US_POSIX")))
    }

    /// Quotes a field that holds a comma, a quote or a line break.
    private static func escaped(_ field: String) -> String {
        guard field.contains(where: { $0 == "," || $0 == "\"" || $0.isNewline }) else { return field }
        return "\"" + field.replacing("\"", with: "\"\"") + "\""
    }

    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(exportedContentType: .commaSeparatedText) { export in
            Data(export.text.utf8)
        }
        .suggestedFileName { $0.fileName }
    }
}
