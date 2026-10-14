import Foundation

nonisolated extension CodeContent {
    /// One line for the history and the creator's list: the part people recognise.
    var summary: String {
        switch self {
        case let .link(url):
            let host = url.host() ?? url.absoluteString
            let path = url.path()
            return path.count > 1 ? host + path : host
        case let .text(text): return text.split(whereSeparator: \.isNewline).first.map(String.init) ?? text
        case let .wifi(network): return network.ssid
        case let .contact(card): return card.name.isEmpty ? card.organization : card.name
        case let .email(message): return message.address
        case let .phone(number): return number
        case let .textMessage(message): return message.number
        case let .location(point):
            let style = FloatingPointFormatStyle<Double>.number.precision(.fractionLength(0...5))
            return "\(point.latitude.formatted(style)), \(point.longitude.formatted(style))"
        case let .event(event): return event.title.isEmpty ? event.start.formatted(date: .abbreviated, time: .shortened) : event.title
        case let .product(number): return number
        }
    }
}
