import Foundation
import SQLite3

/// Reads the 1.0's SQLite file, read-only, with the system's SQLite: no dependency, and the file stays as it is.
nonisolated enum LegacyDatabase {
    enum Failure: Error {
        case cannotOpen
        case cannotRead
    }

    /// Where the Expo 1.0 kept it: `Documents/SQLite/sbu_subscriptions.db` (expo-sqlite's default directory).
    static func url(in documents: URL = .documentsDirectory) -> URL {
        documents.appending(path: "SQLite/sbu_subscriptions.db")
    }

    /// Every row; a row with a missing column comes back as a row the conversion rejects, never as a crash.
    static func rows(at url: URL) throws(Failure) -> [LegacyRow] {
        var db: OpaquePointer?
        guard sqlite3_open_v2(url.path(percentEncoded: false), &db, SQLITE_OPEN_READONLY, nil) == SQLITE_OK else {
            sqlite3_close(db)
            throw .cannotOpen
        }
        defer { sqlite3_close(db) }
        let sql = """
            SELECT id, name, amount, currency, billing_cycle, next_renewal_date, category, icon_slug,
                   is_trial, trial_ends_at, reminder_days_before, notes, created_at
            FROM subscriptions ORDER BY id
            """
        var statement: OpaquePointer?
        guard sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK else { throw .cannotRead }
        defer { sqlite3_finalize(statement) }
        var rows: [LegacyRow] = []
        while true {
            let step = sqlite3_step(statement)
            if step == SQLITE_DONE { break }
            guard step == SQLITE_ROW else { throw .cannotRead }
            func text(_ column: Int32) -> String? {
                sqlite3_column_text(statement, column).map { String(cString: $0) }
            }
            rows.append(LegacyRow(
                id: Int(sqlite3_column_int64(statement, 0)),
                name: text(1) ?? "",
                amount: sqlite3_column_double(statement, 2),
                currency: text(3) ?? "",
                billingCycle: text(4) ?? "",
                nextRenewalDate: text(5) ?? "",
                category: text(6),
                iconSlug: text(7),
                isTrial: sqlite3_column_int(statement, 8) != 0,
                trialEndsAt: text(9),
                reminderDaysBefore: Int(sqlite3_column_int(statement, 10)),
                notes: text(11),
                createdAt: text(12) ?? ""
            ))
        }
        return rows
    }
}
