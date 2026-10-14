import Foundation

/// What a code says, worked out from its text: the result screen offers the actions that fit.
nonisolated enum CodeContent: Equatable, Sendable {
    case link(URL)
    case text(String)
    case wifi(WiFiNetwork)
    case contact(ContactCard)
    case email(EmailMessage)
    case phone(String)
    case textMessage(TextMessage)
    case location(GeoPoint)
    case event(CalendarEvent)
    /// The number on a product (EAN, UPC), to look up on the web.
    case product(String)

    init(_ raw: String, symbology: Symbology, timeZone: TimeZone = .current) {
        let text = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        let lower = text.lowercased()
        if symbology.isProduct {
            self = .product(text)
        } else if let network = WiFiNetwork(code: text) {
            self = .wifi(network)
        } else if let card = ContactCard(code: text) {
            self = .contact(card)
        } else if let event = CalendarEvent(code: text, timeZone: timeZone) {
            self = .event(event)
        } else if let email = EmailMessage(code: text) {
            self = .email(email)
        } else if let message = TextMessage(code: text) {
            self = .textMessage(message)
        } else if let point = GeoPoint(code: text) {
            self = .location(point)
        } else if lower.hasPrefix("tel:") {
            let number = String(text.dropFirst(4))
            self = number.isEmpty ? .text(text) : .phone(number.removingPercentEncoding ?? number)
        } else if let url = Self.webURL(text) {
            self = .link(url)
        } else {
            self = .text(text)
        }
    }

    /// An http(s) address, or one that starts with `www.`; nothing with spaces or another scheme.
    private static func webURL(_ text: String) -> URL? {
        guard !text.contains(where: \.isWhitespace) else { return nil }
        let lower = text.lowercased()
        let candidate = lower.hasPrefix("www.") ? "https://" + text : text
        guard let url = URL(string: candidate),
              let scheme = url.scheme?.lowercased(), scheme == "http" || scheme == "https",
              let host = url.host(), !host.isEmpty
        else { return nil }
        return url
    }

    /// The kind, for the title of the result and the history.
    var kind: CodeKind {
        switch self {
        case .link: .link
        case .text: .text
        case .wifi: .wifi
        case .contact: .contact
        case .email: .email
        case .phone: .phone
        case .textMessage: .textMessage
        case .location: .location
        case .event: .event
        case .product: .product
        }
    }
}
