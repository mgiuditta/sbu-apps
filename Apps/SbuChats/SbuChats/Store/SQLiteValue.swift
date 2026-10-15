/// A value bound to a statement parameter.
nonisolated enum SQLiteValue: Sendable {
    case integer(Int64)
    case real(Double)
    case text(String)
    case null

    /// Text, or `null` when there is none.
    static func optionalText(_ string: String?) -> SQLiteValue {
        string.map(SQLiteValue.text) ?? .null
    }
}
