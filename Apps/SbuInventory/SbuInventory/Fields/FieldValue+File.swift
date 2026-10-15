import Foundation

extension FieldValue {
    /// Whether the value holds anything for its field's kind.
    var isEmpty: Bool {
        switch definition?.kind ?? .text {
        case .text: (text ?? "").trimmingCharacters(in: .whitespaces).isEmpty
        case .number, .money: number == nil
        case .date: date == nil
        }
    }

    /// The value in the file's form: numbers with a point, days as yyyy-MM-dd.
    func fileText(calendar: Calendar) -> String {
        switch definition?.kind ?? .text {
        case .text: text ?? ""
        case .number, .money: number.map(CSVValue.text) ?? ""
        case .date: date.map { CSVValue.day($0, calendar: calendar) } ?? ""
        }
    }

    /// Sets the value from the file's form for a field of `kind`; text that doesn't read as one stays as text.
    func setFileText(_ value: String, kind: FieldKind, calendar: Calendar) {
        switch kind {
        case .text:
            text = value
        case .number, .money:
            if let number = CSVValue.decimal(value) { self.number = number } else { text = value }
        case .date:
            if let date = CSVValue.date(value, calendar: calendar) { self.date = date } else { text = value }
        }
    }
}
