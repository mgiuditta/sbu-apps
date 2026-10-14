import Foundation

/// A text message to send, from `SMSTO:number:text` or `sms:number?body=text` codes.
nonisolated struct TextMessage: Equatable, Sendable {
    var number: String
    var body: String

    init(number: String, body: String = "") {
        self.number = number
        self.body = body
    }

    init?(code: String) {
        let upper = code.uppercased()
        if upper.hasPrefix("SMSTO:") || upper.hasPrefix("MMSTO:") {
            let parts = code.dropFirst(6).split(separator: ":", maxSplits: 1, omittingEmptySubsequences: false).map(String.init)
            self.init(number: parts.first ?? "", body: parts.count > 1 ? parts[1] : "")
        } else if upper.hasPrefix("SMS:") {
            let rest = code.dropFirst(4)
            let parts = rest.split(separator: "?", maxSplits: 1).map(String.init)
            let body = parts.count > 1
                ? URLComponents(string: "?" + parts[1])?.queryItems?.first { $0.name.lowercased() == "body" }?.value ?? ""
                : ""
            // Some writers use sms:number:text.
            let numberAndText = (parts.first ?? "").split(separator: ":", maxSplits: 1).map(String.init)
            self.init(number: numberAndText.first ?? "", body: body.isEmpty && numberAndText.count > 1 ? numberAndText[1] : body)
        } else {
            return nil
        }
        guard !number.isEmpty else { return nil }
    }

    /// Opens Messages with the number and, from iOS 17, the text.
    var url: URL? {
        var components = URLComponents()
        components.scheme = "sms"
        components.path = number
        if !body.isEmpty { components.queryItems = [URLQueryItem(name: "body", value: body)] }
        return components.url
    }

    var code: String { body.isEmpty ? "SMSTO:\(number)" : "SMSTO:\(number):\(body)" }
}
