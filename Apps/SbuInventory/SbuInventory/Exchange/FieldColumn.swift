/// The column of a custom field: `campo:data:Garanzia fino al`, so an import rebuilds the field with its kind.
nonisolated struct FieldColumn: Hashable, Sendable {
    static let prefix = "campo:"

    let name: String
    let kind: FieldKind

    var header: String {
        Self.prefix + kind.rawValue + ":" + name
    }

    init(name: String, kind: FieldKind) {
        self.name = name
        self.kind = kind
    }

    /// Reads `campo:<kind>:<name>`, or `campo:<name>` as a text field.
    init?(header: String) {
        let trimmed = header.trimmingCharacters(in: .whitespaces)
        guard trimmed.lowercased().hasPrefix(Self.prefix) else { return nil }
        let rest = trimmed.dropFirst(Self.prefix.count)
        if let colon = rest.firstIndex(of: ":"), let kind = FieldKind(rawValue: String(rest[..<colon]).lowercased()) {
            name = String(rest[rest.index(after: colon)...]).trimmingCharacters(in: .whitespaces)
            self.kind = kind
        } else {
            name = String(rest).trimmingCharacters(in: .whitespaces)
            kind = .text
        }
        if name.isEmpty { return nil }
    }
}
