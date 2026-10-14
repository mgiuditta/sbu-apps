import Foundation

/// An e-mail to write, from `mailto:`, `MATMSG:` or `SMTP:` codes.
nonisolated struct EmailMessage: Equatable, Sendable {
    var address: String
    var subject: String
    var body: String

    init(address: String, subject: String = "", body: String = "") {
        self.address = address
        self.subject = subject
        self.body = body
    }

    init?(code: String) {
        let upper = code.uppercased()
        if upper.hasPrefix("MAILTO:") {
            let components = URLComponents(string: code)
            let items = components?.queryItems ?? []
            let address = components?.path.removingPercentEncoding ?? String(code.dropFirst(7))
            self.init(
                address: address,
                subject: items.first { $0.name.lowercased() == "subject" }?.value ?? "",
                body: items.first { $0.name.lowercased() == "body" }?.value ?? ""
            )
        } else if upper.hasPrefix("MATMSG:") {
            let fields = FieldList.parse(code, prefix: "MATMSG:")
            self.init(address: fields["TO"] ?? "", subject: fields["SUB"] ?? "", body: fields["BODY"] ?? "")
        } else if upper.hasPrefix("SMTP:") {
            // SMTP:address:subject:body
            let parts = code.dropFirst(5).split(separator: ":", maxSplits: 2, omittingEmptySubsequences: false).map(String.init)
            self.init(address: parts.first ?? "", subject: parts.count > 1 ? parts[1] : "", body: parts.count > 2 ? parts[2] : "")
        } else {
            return nil
        }
        guard !address.isEmpty else { return nil }
    }

    /// The `mailto:` link that opens Mail with the message ready.
    var url: URL? {
        var components = URLComponents()
        components.scheme = "mailto"
        components.path = address
        var items: [URLQueryItem] = []
        if !subject.isEmpty { items.append(URLQueryItem(name: "subject", value: subject)) }
        if !body.isEmpty { items.append(URLQueryItem(name: "body", value: body)) }
        components.queryItems = items.isEmpty ? nil : items
        return components.url
    }

    var code: String { url?.absoluteString ?? "mailto:\(address)" }
}
