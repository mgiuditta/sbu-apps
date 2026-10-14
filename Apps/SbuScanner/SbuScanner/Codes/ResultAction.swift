import Foundation
import SwiftUI

/// What the result screen offers for a code: one main action at the bottom, the others in the list.
nonisolated enum ResultAction: Equatable, Sendable {
    case open(URL)
    case joinWiFi(WiFiNetwork)
    case addContact(ContactCard)
    case addEvent(CalendarEvent)
    case copy(String)
    case copyPassword(String)
    case searchWeb(String)

    /// The main action for what the code says.
    static func primary(for content: CodeContent, raw: String) -> ResultAction {
        switch content {
        case let .link(url): .open(url)
        case let .wifi(network): .joinWiFi(network)
        case let .contact(card): .addContact(card)
        case let .email(message): message.url.map(ResultAction.open) ?? .copy(raw)
        case let .phone(number): Self.telURL(number).map(ResultAction.open) ?? .copy(raw)
        case let .textMessage(message): message.url.map(ResultAction.open) ?? .copy(raw)
        case let .location(point): point.mapsURL.map(ResultAction.open) ?? .copy(raw)
        case let .event(event): .addEvent(event)
        case let .product(number): .searchWeb(number)
        case .text: .copy(raw)
        }
    }

    /// The other actions, after the main one; sharing is always there too, as a share link.
    static func secondary(for content: CodeContent, raw: String) -> [ResultAction] {
        var actions: [ResultAction] = []
        if case let .wifi(network) = content, !network.password.isEmpty { actions.append(.copyPassword(network.password)) }
        if primary(for: content, raw: raw) != .copy(raw) { actions.append(.copy(raw)) }
        if case let .text(text) = content { actions.append(.searchWeb(text)) }
        return actions
    }

    /// Safari with the default search engine; the app itself goes nowhere.
    static func searchURL(_ query: String) -> URL? {
        // x-web-search://?query, the form Safari reads.
        guard let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed.subtracting(CharacterSet(charactersIn: "&=+?"))) else { return nil }
        return URL(string: "x-web-search://?\(encoded)")
    }

    private static func telURL(_ number: String) -> URL? {
        URL(string: "tel:\(number.filter { $0.isNumber || $0 == "+" })")
    }

    func title(for content: CodeContent) -> LocalizedStringKey {
        switch self {
        case .open:
            switch content {
            case .link: "Apri il link"
            case .email: "Scrivi email"
            case .phone: "Chiama"
            case .textMessage: "Scrivi messaggio"
            case .location: "Apri in Mappe"
            default: "Apri"
            }
        case .joinWiFi: "Connetti"
        case .addContact: "Aggiungi ai contatti"
        case .addEvent: "Aggiungi al calendario"
        case .copy: "Copia"
        case .copyPassword: "Copia password"
        case .searchWeb: "Cerca sul web"
        }
    }

    var systemImage: String {
        switch self {
        case .open: "arrow.up.forward.app"
        case .joinWiFi: "wifi"
        case .addContact: "person.crop.circle.badge.plus"
        case .addEvent: "calendar.badge.plus"
        case .copy: "doc.on.doc"
        case .copyPassword: "key"
        case .searchWeb: "magnifyingglass"
        }
    }
}
