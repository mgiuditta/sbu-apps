/// A custom field value as the file holds it: the field it belongs to and its text,
/// numbers with a point and dates as yyyy-MM-dd whatever the language.
nonisolated struct CustomFieldCell: Equatable, Sendable {
    let column: FieldColumn
    let value: String
}
