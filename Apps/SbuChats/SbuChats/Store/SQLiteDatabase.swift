import Foundation
import SQLite3

/// A connection to the system's SQLite, with only what the chat store needs.
///
/// Not thread-safe on its own: `ChatStore` owns the one connection and serialises every call.
nonisolated final class SQLiteDatabase {
    private var handle: OpaquePointer?

    /// Opens or creates the database at `url`, or an in-memory one when `url` is `nil`.
    init(url: URL?) throws(SQLiteError) {
        let path = url?.path(percentEncoded: false) ?? ":memory:"
        let flags = SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE | SQLITE_OPEN_NOMUTEX
        let status = sqlite3_open_v2(path, &handle, flags, nil)
        guard status == SQLITE_OK else {
            let error = SQLiteError(code: status, message: handle.map { String(cString: sqlite3_errmsg($0)) } ?? "open")
            sqlite3_close(handle)
            handle = nil
            throw error
        }
    }

    deinit {
        sqlite3_close_v2(handle)
    }

    /// Runs one or more statements without results.
    func execute(_ sql: String) throws(SQLiteError) {
        var message: UnsafeMutablePointer<CChar>?
        let status = sqlite3_exec(handle, sql, nil, nil, &message)
        guard status == SQLITE_OK else {
            let text = message.map { String(cString: $0) } ?? lastErrorMessage
            sqlite3_free(message)
            throw SQLiteError(code: status, message: text)
        }
    }

    /// Compiles one statement.
    func prepare(_ sql: String) throws(SQLiteError) -> SQLiteStatement {
        var statement: OpaquePointer?
        let status = sqlite3_prepare_v3(handle, sql, -1, UInt32(SQLITE_PREPARE_PERSISTENT), &statement, nil)
        guard status == SQLITE_OK, let statement else {
            sqlite3_finalize(statement)
            throw SQLiteError(code: status, message: lastErrorMessage)
        }
        return SQLiteStatement(statement, database: self)
    }

    /// Runs `body` in a transaction: committed if it returns, rolled back if it throws.
    func transaction<Result>(_ body: () throws -> Result) throws -> Result {
        try execute("BEGIN IMMEDIATE")
        do {
            let result = try body()
            try execute("COMMIT")
            return result
        } catch {
            try? execute("ROLLBACK")
            throw error
        }
    }

    /// The rowid of the last row inserted.
    var lastInsertedRowID: Int64 { sqlite3_last_insert_rowid(handle) }

    /// Rows changed by the last statement.
    var changes: Int { Int(sqlite3_changes(handle)) }

    var lastErrorMessage: String {
        handle.map { String(cString: sqlite3_errmsg($0)) } ?? "closed"
    }
}
