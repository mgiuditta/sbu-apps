/// A failure reported by SQLite, with its message.
nonisolated struct SQLiteError: Error, CustomStringConvertible, Sendable {
    let code: Int32
    let message: String

    var description: String { "SQLite \(code): \(message)" }
}
