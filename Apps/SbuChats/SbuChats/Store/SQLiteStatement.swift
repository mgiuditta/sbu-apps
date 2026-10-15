import Foundation
import SQLite3

/// A compiled statement: bind parameters, step through rows, read columns.
nonisolated final class SQLiteStatement {
    /// Tells SQLite to copy bound text, since Swift strings don't outlive the call.
    private static let transient = unsafeBitCast(-1, to: sqlite3_destructor_type.self)

    private let statement: OpaquePointer
    private let database: SQLiteDatabase

    init(_ statement: OpaquePointer, database: SQLiteDatabase) {
        self.statement = statement
        self.database = database
    }

    deinit {
        sqlite3_finalize(statement)
    }

    /// Binds values to `?1`, `?2`… in order, after clearing earlier bindings and resetting.
    @discardableResult
    func bind(_ values: SQLiteValue...) throws(SQLiteError) -> SQLiteStatement {
        try bind(values)
    }

    @discardableResult
    func bind(_ values: [SQLiteValue]) throws(SQLiteError) -> SQLiteStatement {
        sqlite3_reset(statement)
        sqlite3_clear_bindings(statement)
        for (offset, value) in values.enumerated() {
            let index = Int32(offset + 1)
            let status = switch value {
            case let .integer(number): sqlite3_bind_int64(statement, index, number)
            case let .real(number): sqlite3_bind_double(statement, index, number)
            case let .text(string): sqlite3_bind_text(statement, index, string, -1, Self.transient)
            case .null: sqlite3_bind_null(statement, index)
            }
            guard status == SQLITE_OK else { throw SQLiteError(code: status, message: database.lastErrorMessage) }
        }
        return self
    }

    /// Runs a statement that returns no rows.
    func run() throws(SQLiteError) {
        let status = sqlite3_step(statement)
        sqlite3_reset(statement)
        guard status == SQLITE_DONE || status == SQLITE_ROW else {
            throw SQLiteError(code: status, message: database.lastErrorMessage)
        }
    }

    /// Calls `row` for each result row.
    func forEachRow(_ row: (SQLiteStatement) throws -> Void) throws {
        defer { sqlite3_reset(statement) }
        while true {
            let status = sqlite3_step(statement)
            if status == SQLITE_DONE { return }
            guard status == SQLITE_ROW else { throw SQLiteError(code: status, message: database.lastErrorMessage) }
            try row(self)
        }
    }

    /// Every result row, mapped.
    func map<Row>(_ transform: (SQLiteStatement) throws -> Row) throws -> [Row] {
        var rows: [Row] = []
        try forEachRow { rows.append(try transform($0)) }
        return rows
    }

    func int(_ column: Int32) -> Int64 {
        sqlite3_column_int64(statement, column)
    }

    func double(_ column: Int32) -> Double {
        sqlite3_column_double(statement, column)
    }

    func text(_ column: Int32) -> String? {
        sqlite3_column_text(statement, column).map { String(cString: $0) }
    }

    func isNull(_ column: Int32) -> Bool {
        sqlite3_column_type(statement, column) == SQLITE_NULL
    }
}
