import Foundation


/// A contact from a vCard (`BEGIN:VCARD`) or a MECARD (`MECARD:N:…;;`) code.
nonisolated struct ContactCard: Equatable, Sendable {
    var name: String
    var organization: String
    var phones: [String]
    var emails: [String]
    var website: String
    var address: String

    init(name: String = "", organization: String = "", phones: [String] = [], emails: [String] = [], website: String = "", address: String = "") {
        self.name = name
        self.organization = organization
        self.phones = phones
        self.emails = emails
        self.website = website
        self.address = address
    }

    init?(code: String) {
        let upper = code.uppercased()
        if upper.hasPrefix("BEGIN:VCARD") {
            self.init(vCard: code)
        } else if upper.hasPrefix("MECARD:") {
            self.init(meCard: code)
        } else {
            return nil
        }
        guard !isEmpty else { return nil }
    }

    var isEmpty: Bool {
        name.isEmpty && organization.isEmpty && phones.isEmpty && emails.isEmpty && website.isEmpty && address.isEmpty
    }

    /// vCard 3.0, which Contacts reads and every scanner understands.
    var vCard: String {
        var lines = ["BEGIN:VCARD", "VERSION:3.0"]
        let parts = name.split(separator: " ", maxSplits: 1).map(String.init)
        let family = parts.count > 1 ? parts[1] : ""
        let given = parts.first ?? ""
        lines.append("N:\(Self.escape(family));\(Self.escape(given));;;")
        lines.append("FN:\(Self.escape(name.isEmpty ? organization : name))")
        if !organization.isEmpty { lines.append("ORG:\(Self.escape(organization))") }
        lines += phones.map { "TEL:\(Self.escape($0))" }
        lines += emails.map { "EMAIL:\(Self.escape($0))" }
        if !website.isEmpty { lines.append("URL:\(Self.escape(website))") }
        if !address.isEmpty { lines.append("ADR:;;\(Self.escape(address));;;;") }
        lines.append("END:VCARD")
        return lines.joined(separator: "\r\n")
    }

    private init(vCard: String) {
        self.init()
        var formatted = ""
        var structured = ""
        for line in Self.unfold(vCard) {
            guard let colon = line.firstIndex(of: ":") else { continue }
            // "TEL;TYPE=CELL" → "TEL"; "item1.EMAIL" → "EMAIL".
            let property = line[..<colon].split(separator: ";").first.map { $0.split(separator: ".").last ?? $0 }.map { $0.uppercased() } ?? ""
            let value = String(line[line.index(after: colon)...])
            switch property {
            case "FN": formatted = Self.unescape(value)
            case "N":
                // Family;Given;Additional;Prefix;Suffix
                let parts = value.split(separator: ";", omittingEmptySubsequences: false).map { Self.unescape(String($0)) }
                structured = [parts.count > 1 ? parts[1] : "", parts.first ?? ""].filter { !$0.isEmpty }.joined(separator: " ")
            case "ORG": organization = Self.unescape(value).replacing(";", with: " ").trimmingCharacters(in: .whitespaces)
            case "TEL": phones.append(Self.unescape(value))
            case "EMAIL": emails.append(Self.unescape(value))
            case "URL": website = Self.unescape(value)
            case "ADR":
                address = value.split(separator: ";", omittingEmptySubsequences: false)
                    .map { Self.unescape(String($0)).trimmingCharacters(in: .whitespaces) }
                    .filter { !$0.isEmpty }
                    .joined(separator: ", ")
            default: break
            }
        }
        name = formatted.isEmpty ? structured : formatted
    }

    private init(meCard: String) {
        let fields = FieldList.parse(meCard, prefix: "MECARD:")
        // MECARD names are "Family,Given".
        let name = (fields["N"] ?? "").split(separator: ",").reversed().joined(separator: " ")
        self.init(
            name: name,
            organization: fields["ORG"] ?? "",
            phones: fields["TEL"].map { [$0] } ?? [],
            emails: fields["EMAIL"].map { [$0] } ?? [],
            website: fields["URL"] ?? "",
            address: fields["ADR"] ?? ""
        )
    }

    /// Joins folded lines (a line that starts with a space or tab continues the previous one).
    private static func unfold(_ text: String) -> [String] {
        var lines: [String] = []
        for raw in text.split(omittingEmptySubsequences: true, whereSeparator: \.isNewline) {
            if let first = raw.first, first == " " || first == "\t", !lines.isEmpty {
                lines[lines.count - 1] += raw.dropFirst()
            } else {
                lines.append(String(raw))
            }
        }
        return lines
    }

    private static func escape(_ value: String) -> String {
        value.replacing("\\", with: "\\\\").replacing(",", with: "\\,").replacing(";", with: "\\;").replacing("\n", with: "\\n")
    }

    private static func unescape(_ value: String) -> String {
        value.replacing("\\n", with: "\n").replacing("\\N", with: "\n").replacing("\\,", with: ",").replacing("\\;", with: ";").replacing("\\\\", with: "\\")
    }
}
