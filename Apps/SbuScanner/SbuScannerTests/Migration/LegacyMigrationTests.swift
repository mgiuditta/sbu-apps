import Foundation
import SQLite3
import SwiftData
import Testing
@testable import SbuScanner

/// A 1.x database with its exact schema, written the way the Expo app wrote it: WAL, dates as UTC
/// `toISOString()`, expo-camera's types for codes read, bwip-js's names for codes made.
nonisolated final class LegacyFixture {
    let documents: URL
    private var db: OpaquePointer?

    /// - Parameter version: "1.1" with folders and every column, "1.0" with the first table only.
    init(version: String = "1.1") throws {
        documents = URL.temporaryDirectory.appending(path: "legacy-\(UUID().uuidString)")
        let folder = documents.appending(path: "SQLite")
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        sqlite3_open(folder.appending(path: "sbu_barcode_scanner.db").path(percentEncoded: false), &db)
        exec("PRAGMA journal_mode = WAL;")
        if version == "1.0" {
            exec("CREATE TABLE scan_history (id INTEGER PRIMARY KEY AUTOINCREMENT, data TEXT NOT NULL, code_type TEXT NOT NULL, scanned_at TEXT NOT NULL);")
        } else {
            exec("""
                CREATE TABLE scan_history (id INTEGER PRIMARY KEY AUTOINCREMENT, data TEXT NOT NULL, code_type TEXT NOT NULL,
                  scanned_at TEXT NOT NULL, folder_id INTEGER, symbology TEXT, color TEXT, code_type_id TEXT);
                CREATE TABLE folders (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, icon TEXT NOT NULL,
                  color TEXT NOT NULL, sort_order INTEGER NOT NULL, created_at TEXT NOT NULL, updated_at TEXT NOT NULL);
                """)
        }
    }

    /// Left open on purpose: the rows stay in the -wal file, as when the 1.x was killed.
    func exec(_ sql: String) {
        sqlite3_exec(db, sql, nil, nil, nil)
    }

    var databaseURL: URL { LegacyDatabase.url(in: documents) }

    deinit {
        sqlite3_close(db)
        try? FileManager.default.removeItem(at: documents)
    }
}

struct LegacyMigrationTests {
    let defaults = UserDefaults(suiteName: "LegacyMigrationTests.\(UUID().uuidString)")!

    func context() throws -> ModelContext {
        ModelContext(try ModelContainer.scanner(inMemory: true))
    }

    func records(_ context: ModelContext) throws -> [ScanRecord] {
        try context.fetch(FetchDescriptor<ScanRecord>(sortBy: [SortDescriptor(\.date)]))
    }

    @Test func bringsOverCodesFoldersAndDates() throws {
        let fixture = try LegacyFixture()
        fixture.exec("""
            INSERT INTO folders (name, icon, color, sort_order, created_at, updated_at) VALUES ('Lavoro', 'briefcase', '#000', 1, '2026-09-01T08:00:00.000Z', '2026-09-01T08:00:00.000Z');
            INSERT INTO scan_history (data, code_type, scanned_at, folder_id, symbology) VALUES ('https://sbu.dev', 'qr', '2026-10-01T09:30:00.000Z', 1, 'qrcode');
            INSERT INTO scan_history (data, code_type, scanned_at) VALUES ('4006381333931', 'ean13', '2026-10-02T10:00:00.000Z');
            INSERT INTO scan_history (data, code_type, scanned_at, symbology, color, code_type_id) VALUES ('WIFI:T:WPA;S:Casa;P:pw;;', 'Wi-Fi', '2026-10-03T11:00:00.000Z', 'qrcode', '#0A0A00', 'qr-wifi');
            """)
        let context = try context()
        let outcome = LegacyMigration.run(context, documents: fixture.documents, defaults: defaults)
        #expect(outcome == LegacyMigration.Outcome(imported: 3))

        let imported = try records(context)
        #expect(imported.map(\.raw) == ["https://sbu.dev", "4006381333931", "WIFI:T:WPA;S:Casa;P:pw;;"])
        #expect(imported.map(\.symbology) == [.qr, .ean13, .qr])
        #expect(imported[0].date == Date(timeIntervalSince1970: 1_790_847_000))
        #expect(imported[0].folder?.name == "Lavoro")
        #expect(imported[1].folder == nil)
        #expect(imported[2].content.kind == .wifi)
        #expect(defaults.bool(forKey: LegacyMigration.Key.done))
    }

    @Test func aWALFileIsReadAndTheOriginalIsLeftAsItWas() throws {
        let fixture = try LegacyFixture()
        fixture.exec("INSERT INTO scan_history (data, code_type, scanned_at) VALUES ('ciao', 'qr', '2026-10-01T09:30:00.000Z');")
        let path = fixture.databaseURL.path(percentEncoded: false)
        let before = try FileManager.default.attributesOfItem(atPath: path)[.modificationDate] as? Date
        let walBefore = try Data(contentsOf: URL(filePath: path + "-wal"))

        let context = try context()
        #expect(LegacyMigration.run(context, documents: fixture.documents, defaults: defaults).imported == 1)
        #expect(try FileManager.default.attributesOfItem(atPath: path)[.modificationDate] as? Date == before)
        #expect(try Data(contentsOf: URL(filePath: path + "-wal")) == walBefore)
    }

    @Test func aVersion10DatabaseWithoutFoldersOrSymbologies() throws {
        let fixture = try LegacyFixture(version: "1.0")
        fixture.exec("INSERT INTO scan_history (data, code_type, scanned_at) VALUES ('0123456789012', 'upc_a', '2026-08-01T09:30:00Z');")
        let context = try context()
        #expect(LegacyMigration.run(context, documents: fixture.documents, defaults: defaults) == LegacyMigration.Outcome(imported: 1))
        #expect(try records(context).first?.symbology == .ean13)
    }

    @Test func runningAgainAddsOnlyWhatIsMissing() throws {
        let fixture = try LegacyFixture()
        fixture.exec("""
            INSERT INTO folders (name, icon, color, sort_order, created_at, updated_at) VALUES ('Casa', 'house', '#000', 1, '2026-09-01T08:00:00.000Z', '2026-09-01T08:00:00.000Z');
            INSERT INTO scan_history (data, code_type, scanned_at, folder_id) VALUES ('uno', 'qr', '2026-10-01T09:30:00.000Z', 1);
            """)
        let context = try context()
        LegacyMigration.run(context, documents: fixture.documents, defaults: defaults)
        fixture.exec("INSERT INTO scan_history (data, code_type, scanned_at, folder_id) VALUES ('due', 'qr', '2026-10-02T09:30:00.000Z', 1);")
        #expect(LegacyMigration.run(context, documents: fixture.documents, defaults: defaults).imported == 1)
        #expect(try records(context).map(\.raw) == ["uno", "due"])
        #expect(try context.fetchCount(FetchDescriptor<ScanFolder>()) == 1)
        #expect(try records(context).allSatisfy { $0.folder?.name == "Casa" })
    }

    @Test func aBrokenRowIsSkippedAndCountedAndTheRestComes() throws {
        let fixture = try LegacyFixture()
        fixture.exec("""
            INSERT INTO scan_history (data, code_type, scanned_at) VALUES ('buono', 'qr', '2026-10-01T09:30:00.000Z');
            INSERT INTO scan_history (data, code_type, scanned_at) VALUES ('data rotta', 'qr', 'ieri');
            INSERT INTO scan_history (data, code_type, scanned_at) VALUES ('', 'qr', '2026-10-01T09:30:00.000Z');
            """)
        let context = try context()
        #expect(LegacyMigration.run(context, documents: fixture.documents, defaults: defaults) == LegacyMigration.Outcome(imported: 1, skipped: 2))
        #expect(!defaults.bool(forKey: LegacyMigration.Key.done))
        #expect(defaults.integer(forKey: LegacyMigration.Key.skipped) == 2)
    }

    @Test func aNewInstallIsDoneAtOnce() throws {
        let context = try context()
        let empty = URL.temporaryDirectory.appending(path: "none-\(UUID().uuidString)")
        #expect(LegacyMigration.runIfNeeded(context, documents: empty, defaults: defaults) == LegacyMigration.Outcome())
        #expect(defaults.bool(forKey: LegacyMigration.Key.done))
        #expect(LegacyMigration.runIfNeeded(context, documents: empty, defaults: defaults) == nil)
    }

    @Test func aFileThatIsNotADatabaseIsUnreadable() throws {
        let documents = URL.temporaryDirectory.appending(path: "bad-\(UUID().uuidString)")
        defer { try? FileManager.default.removeItem(at: documents) }
        try FileManager.default.createDirectory(at: documents.appending(path: "SQLite"), withIntermediateDirectories: true)
        try Data("non è sqlite".utf8).write(to: LegacyDatabase.url(in: documents))
        let outcome = LegacyMigration.run(try context(), documents: documents, defaults: defaults)
        #expect(outcome.unreadable)
        #expect(!defaults.bool(forKey: LegacyMigration.Key.done))
    }

    @Test(arguments: [
        (String?("qrcode"), "Wi-Fi", Symbology.qr), ("azteccode", "Aztec", .aztec), ("rationalizedCodabar", "Codabar", .codabar),
        ("interleaved2of5", "ITF", .itf14), (nil, "upc_e", .upce), (nil, "datamatrix", .dataMatrix), (nil, "sconosciuto", .qr),
    ])
    func symbologies(bwip: String?, codeType: String, expected: Symbology) {
        #expect(LegacyConversion.symbology(bwip, codeType: codeType) == expected)
    }
}
