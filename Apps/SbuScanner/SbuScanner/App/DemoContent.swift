import Foundation
import SwiftData

/// Made-up codes for screenshots and UI tests, never mixed with the user's own.
enum DemoContent {
    static let scannedLink = "https://sbu.dev/apps/scanner"

    /// A history and a creator list that show what the app does.
    static func seed(_ context: ModelContext, now: Date = .now) {
        let work = ScanFolder(name: String(localized: "Lavoro"))
        context.insert(work)
        let records = [
            ScanRecord(raw: "WIFI:T:WPA;S:Casa Rossi;P:girasole-42;;", symbology: .qr, date: now.addingTimeInterval(-600)),
            ScanRecord(raw: "4006381333931", symbology: .ean13, date: now.addingTimeInterval(-3_600)),
            ScanRecord(raw: "BEGIN:VCARD\r\nVERSION:3.0\r\nN:Bianchi;Giulia;;;\r\nFN:Giulia Bianchi\r\nORG:Studio Bianchi\r\nTEL:+39 02 1234 5678\r\nEMAIL:giulia@example.com\r\nEND:VCARD", symbology: .qr, date: now.addingTimeInterval(-86_400), folder: work),
            ScanRecord(raw: "https://www.museo.example.it/biglietti", symbology: .qr, date: now.addingTimeInterval(-90_000)),
            ScanRecord(raw: "geo:45.4642,9.19", symbology: .qr, date: now.addingTimeInterval(-200_000)),
        ]
        records.forEach(context.insert)
        records[2].isFavorite = true
        context.insert(CreatedCode(title: "Wi-Fi ospiti", kind: .wifi, format: .qr, payload: "WIFI:T:WPA;S:Ospiti;P:benvenuti;;", created: now.addingTimeInterval(-7_200)))
        context.insert(CreatedCode(title: "sbu.dev", kind: .link, format: .qr, payload: "https://sbu.dev", created: now.addingTimeInterval(-100_000)))
        try? context.save()
    }
}
