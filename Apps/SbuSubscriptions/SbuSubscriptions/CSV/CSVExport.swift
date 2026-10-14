import CoreTransferable
import Foundation
import UniformTypeIdentifiers

/// Every subscription as a CSV file you keep where you want: the backup that needs no account.
/// The columns are the 1.0's, then the 2.0's, so an import of either version reads it back.
struct CSVExport: Transferable {
    static let header = ["nome", "importo", "valuta", "ciclo_fatturazione", "prossimo_rinnovo", "categoria", "in_prova", "fine_prova", "note",
                         "stato", "promemoria_giorni", "lista", "metodo_pagamento", "sito"]

    let text: String
    let fileName: String

    init(_ subscriptions: [Subscription], date: Date = .now, calendar: Calendar = .current) {
        let rows = subscriptions.sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }.map { subscription in
            let next = subscription.schedule.nextPayment(onOrAfter: date, in: calendar) ?? subscription.startDate
            return CSVTable.line([
                subscription.name,
                "\(subscription.price)",
                subscription.currencyCode,
                CSVValue.text(for: subscription.cycle),
                Self.day(next, calendar: calendar),
                subscription.category?.name ?? "",
                subscription.trialEndDate == nil ? "no" : "si",
                subscription.trialEndDate.map { Self.day($0, calendar: calendar) } ?? "",
                subscription.notes,
                subscription.status.rawValue,
                subscription.reminderDaysBefore.map(String.init) ?? "-1",
                subscription.list?.name ?? "",
                subscription.paymentMethod,
                subscription.url?.absoluteString ?? "",
            ])
        }
        text = "\u{FEFF}" + ([CSVTable.line(Self.header)] + rows).joined(separator: "\n") + "\n"
        fileName = "sbu-subscriptions-\(Self.day(date, calendar: calendar)).csv"
    }

    /// yyyy-MM-dd in the calendar's time zone: a day, never an instant that could shift.
    static func day(_ date: Date, calendar: Calendar) -> String {
        let parts = calendar.dateComponents([.year, .month, .day], from: date)
        return String(parts.year ?? 0) + "-" + twoDigits(parts.month ?? 0) + "-" + twoDigits(parts.day ?? 0)
    }

    private static func twoDigits(_ number: Int) -> String {
        number < 10 ? "0\(number)" : "\(number)"
    }

    static var transferRepresentation: some TransferRepresentation {
        FileRepresentation(exportedContentType: .commaSeparatedText) { export in
            let url = URL.temporaryDirectory.appending(path: export.fileName)
            try Data(export.text.utf8).write(to: url, options: .atomic)
            return SentTransferredFile(url)
        }
    }
}
