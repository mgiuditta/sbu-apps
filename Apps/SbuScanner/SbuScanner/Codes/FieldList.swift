/// The `KEY:value;KEY:value;;` lists of Wi-Fi, MECARD and MATMSG codes, with `\` escaping `;`, `,`, `:` and `\`.
nonisolated enum FieldList {
    /// The fields after `prefix` (such as `WIFI:`), keys uppercased. The first value of a repeated key wins.
    static func parse(_ text: String, prefix: String) -> [String: String] {
        guard text.uppercased().hasPrefix(prefix) else { return [:] }
        var fields: [String: String] = [:]
        for part in split(String(text.dropFirst(prefix.count))) {
            guard let colon = part.firstIndex(of: ":") else { continue }
            let key = part[..<colon].uppercased()
            let value = unescape(String(part[part.index(after: colon)...]))
            if fields[key] == nil { fields[key] = value }
        }
        return fields
    }

    /// Joins fields into a list, escaping their values, closed by `;;`.
    static func make(prefix: String, _ fields: [(key: String, value: String)]) -> String {
        prefix + fields.filter { !$0.value.isEmpty }.map { "\($0.key):\(escape($0.value));" }.joined() + ";"
    }

    static func escape(_ value: String) -> String {
        var result = ""
        for character in value {
            if "\\;,:\"".contains(character) { result.append("\\") }
            result.append(character)
        }
        return result
    }

    /// Splits on `;` not escaped by `\`, keeping the escapes for `unescape`.
    private static func split(_ text: String) -> [String] {
        var parts: [String] = []
        var current = ""
        var isEscaped = false
        for character in text {
            if isEscaped {
                current.append(character)
                isEscaped = false
            } else if character == "\\" {
                current.append(character)
                isEscaped = true
            } else if character == ";" {
                if !current.isEmpty { parts.append(current) }
                current = ""
            } else {
                current.append(character)
            }
        }
        if !current.isEmpty { parts.append(current) }
        return parts
    }

    private static func unescape(_ value: String) -> String {
        var result = ""
        var isEscaped = false
        for character in value {
            if !isEscaped, character == "\\" {
                isEscaped = true
            } else {
                result.append(character)
                isEscaped = false
            }
        }
        return result
    }
}
