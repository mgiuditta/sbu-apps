import SwiftUI

/// The kinds of content a code can hold, with their name and symbol. Also the kinds the creator makes.
nonisolated enum CodeKind: String, Codable, CaseIterable, Sendable {
    case link
    case text
    case wifi
    case contact
    case email
    case phone
    case textMessage
    case location
    case event
    case product

    var title: LocalizedStringResource {
        switch self {
        case .link: "Link"
        case .text: "Testo"
        case .wifi: "Wi-Fi"
        case .contact: "Contatto"
        case .email: "Email"
        case .phone: "Telefono"
        case .textMessage: "Messaggio"
        case .location: "Posizione"
        case .event: "Evento"
        case .product: "Prodotto"
        }
    }

    var systemImage: String {
        switch self {
        case .link: "link"
        case .text: "text.alignleft"
        case .wifi: "wifi"
        case .contact: "person.crop.circle"
        case .email: "envelope"
        case .phone: "phone"
        case .textMessage: "message"
        case .location: "mappin.and.ellipse"
        case .event: "calendar"
        case .product: "barcode"
        }
    }
}
