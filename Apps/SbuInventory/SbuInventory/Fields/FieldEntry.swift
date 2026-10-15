import Foundation

/// What you typed in one custom field of the item form; which part counts depends on the field's kind.
nonisolated struct FieldEntry: Equatable, Sendable {
    var text = ""
    var number: Decimal?
    var date: Date?

    func isEmpty(for kind: FieldKind) -> Bool {
        switch kind {
        case .text: text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        case .number, .money: number == nil
        case .date: date == nil
        }
    }
}
