import Foundation
import SQLite3

/// Reads the 1.x's SQLite file with the system's SQLite: no dependency, and the file stays as it is.
nonisolated enum LegacyDatabase {
    enum Failure: Error {
        case cannotOpen
        case cannotRead
    }

    /// Where the Expo 1.x kept it: `Documents/SQLite/sbu_barcode_scanner.db` (expo-sqlite's default directory).
    static func url(in documents: URL = .documentsDirectory) -> URL {
        documents.appending(path: "SQLite/sbu_barcode_scanner.db")
    }

    /// Reads a copy, with its `-wal` and `-shm`: the 1.x wrote in WAL mode, rows can still sit in the
    /// `-wal` of a killed app, and only a writable connection folds them in. The original is never opened.
    static func read(at url: URL) throws(Failure) -> (scans: [LegacyScan], folders: [LegacyFolder]) {
        let copy = URL.temporaryDirectory.appending(path: "legacy-\(UUID().uuidString)")
        defer { try? FileManager.default.removeItem(at: copy) }
        do {
            try FileManager.default.createDirectory(at: copy, withIntermediateDirectories: true)
            for suffix in ["", "-wal", "-shm"] {
                let source = URL(filePath: url.path(percentEncoded: false) + suffix)
                guard FileManager.default.fileExists(atPath: source.path(percentEncoded: false)) else { continue }
                try FileManager.default.copyItem(at: source, to: copy.appending(path: url.lastPathComponent + suffix))
            }
        } catch {
            throw .cannotOpen
        }
        var db: OpaquePointer?
        guard sqlite3_open_v2(copy.appending(path: url.lastPathComponent).path(percentEncoded: false), &db, SQLITE_OPEN_READWRITE, nil) == SQLITE_OK else {
            sqlite3_close(db)
            throw .cannotOpen
        }
        defer { sqlite3_close(db) }
        // A 1.0 that never ran the 1.1 has no folder_id or symbology: those read as null.
        let columns = Set((try? rows(db, "PRAGMA table_info(scan_history)") { text($0, 1) ?? "" }) ?? [])
        let optional = ["folder_id", "symbology"].map { columns.contains($0) ? $0 : "NULL" }.joined(separator: ", ")
        let scans = try rows(db, "SELECT id, data, code_type, scanned_at, \(optional) FROM scan_history ORDER BY id") { statement in
            LegacyScan(
                id: Int(sqlite3_column_int64(statement, 0)),
                data: text(statement, 1) ?? "",
                codeType: text(statement, 2) ?? "",
                scannedAt: text(statement, 3) ?? "",
                folderID: sqlite3_column_type(statement, 4) == SQLITE_NULL ? nil : Int(sqlite3_column_int64(statement, 4)),
                symbology: text(statement, 5)
            )
        }
        // A 1.0 database has no folders table: no folders, not a failure.
        let folders = (try? rows(db, "SELECT id, name, created_at FROM folders ORDER BY sort_order, id") { statement in
            LegacyFolder(id: Int(sqlite3_column_int64(statement, 0)), name: text(statement, 1) ?? "", createdAt: text(statement, 2) ?? "")
        }) ?? []
        return (scans, folders)
    }

    private static func rows<Row>(_ db: OpaquePointer?, _ sql: String, _ make: (OpaquePointer?) -> Row) throws(Failure) -> [Row] {
        var statement: OpaquePointer?
        guard sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK else {
            sqlite3_finalize(statement)
            throw .cannotRead
        }
        defer { sqlite3_finalize(statement) }
        var rows: [Row] = []
        while true {
            let step = sqlite3_step(statement)
            if step == SQLITE_DONE { break }
            guard step == SQLITE_ROW else { throw .cannotRead }
            rows.append(make(statement))
        }
        return rows
    }

    private static func text(_ statement: OpaquePointer?, _ column: Int32) -> String? {
        sqlite3_column_text(statement, column).map { String(cString: $0) }
    }
}
