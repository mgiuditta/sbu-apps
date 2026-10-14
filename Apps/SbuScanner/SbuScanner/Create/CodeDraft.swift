import Foundation

/// The creator's form: the fields of every kind, and the text the code will hold.
nonisolated struct CodeDraft: Equatable, Sendable {
    var kind: CodeKind
    var format: CodeFormat
    var title = ""

    var text = ""
    var link = ""
    var wifi = WiFiNetwork(ssid: "")
    var contact = ContactCard()
    var contactPhone = ""
    var contactEmail = ""
    var email = EmailMessage(address: "")
    var phone = ""
    var message = TextMessage(number: "")
    var latitude = ""
    var longitude = ""
    var event = CalendarEvent(title: "", start: .now, end: .now.addingTimeInterval(3600))
    var productNumber = ""

    init(kind: CodeKind, start: Date = .now) {
        self.kind = kind
        format = kind == .product ? .ean13 : .qr
        let hour = Calendar.current.nextDate(after: start, matching: DateComponents(minute: 0), matchingPolicy: .nextTime) ?? start
        event = CalendarEvent(title: "", start: hour, end: hour.addingTimeInterval(3600))
    }

    /// The formats this kind can be drawn in: barcodes only hold a number or a short text.
    var formats: [CodeFormat] {
        switch kind {
        case .product: [.ean13, .ean8, .upca, .upce, .itf14, .code128, .code39, .codabar]
        case .text: [.qr, .aztec, .pdf417, .code128, .code39, .codabar]
        default: [.qr, .aztec, .pdf417]
        }
    }

    /// What the code will say; `nil` while a required field is empty or wrong.
    var payload: String? {
        let value: String? = switch kind {
        case .text: text.isEmpty ? nil : text
        case .link: Self.normalizedLink(link)
        case .wifi: wifi.ssid.isEmpty ? nil : wifi.code
        case .contact: contactCard.isEmpty ? nil : contactCard.vCard
        case .email: email.address.contains("@") ? email.code : nil
        case .phone: Self.phoneDigits(phone).map { "tel:\($0)" }
        case .textMessage: Self.phoneDigits(message.number).map { TextMessage(number: $0, body: message.body).code }
        case .location: Self.number(latitude).flatMap { lat in Self.number(longitude).flatMap { GeoPoint(latitude: lat, longitude: $0) } }?.code
        case .event: event.title.isEmpty || (event.end.map { $0 < event.start } ?? false) ? nil : event.code
        case .product: productNumber.filter(\.isNumber).isEmpty ? nil : productNumber.filter { !$0.isWhitespace }
        }
        // Check digits added, Code 39 in capitals: the list keeps what the code really says.
        guard let value, let code = format.normalized(value), CodeGraphic(code, format: format) != nil else { return nil }
        return code
    }

    /// A name for the list of created codes when the user gives none.
    var suggestedTitle: String {
        switch kind {
        case .text: String(text.prefix(40))
        case .link: Self.normalizedLink(link).flatMap { URL(string: $0)?.host() } ?? link
        case .wifi: wifi.ssid
        case .contact: contact.name.isEmpty ? contact.organization : contact.name
        case .email: email.address
        case .phone: phone
        case .textMessage: message.number
        case .location: "\(latitude), \(longitude)"
        case .event: event.title
        case .product: productNumber
        }
    }

    private var contactCard: ContactCard {
        var card = contact
        card.phones = contactPhone.isEmpty ? [] : [contactPhone]
        card.emails = contactEmail.isEmpty ? [] : [contactEmail]
        return card
    }

    /// `sbu.dev` becomes `https://sbu.dev`; anything with spaces or no dot is not a link.
    static func normalizedLink(_ text: String) -> String? {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, !trimmed.contains(where: \.isWhitespace) else { return nil }
        let candidate = trimmed.contains("://") ? trimmed : "https://" + trimmed
        guard let url = URL(string: candidate), let host = url.host(), host.contains(".") else { return nil }
        return candidate
    }

    /// Keeps `+` and digits; at least three digits.
    static func phoneDigits(_ text: String) -> String? {
        let kept = text.trimmingCharacters(in: .whitespaces).enumerated().filter { $0.element.isNumber || ($0.element == "+" && $0.offset == 0) }.map(\.element)
        return kept.filter(\.isNumber).count >= 3 ? String(kept) : nil
    }

    /// Decimal comma or point, whatever the keyboard gives.
    private static func number(_ text: String) -> Double? {
        Double(text.trimmingCharacters(in: .whitespaces).replacing(",", with: "."))
    }
}
