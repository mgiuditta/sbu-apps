import Foundation

/// Remote messages of Android TV Remote v2 (port 6466), after pairing.
///
/// Field numbers from the public `remotemessage.proto` that open-source clients describe
/// (androidtvremote2, androidtv-remote). On connect the TV sends a configure and a set-active
/// message, the client answers both; then the TV pings and the client must answer every ping
/// or the TV closes the connection. To verify on a real TV: the IME fields used for text.
nonisolated enum AndroidRemoteMessage {
    enum Field {
        static let configure = 1
        static let setActive = 2
        static let error = 3
        static let pingRequest = 8
        static let pingResponse = 9
        static let keyInject = 10
        static let imeKeyInject = 20
        static let imeBatchEdit = 21
        static let start = 40
        static let appLinkLaunch = 90
    }

    /// The feature flags the client asks for: ping, key, IME, power, volume, app link (622).
    static let features = 622

    enum Direction: Int, Sendable {
        case startLong = 1
        case endLong = 2
        case short = 3

        init(_ action: KeyAction) {
            switch action {
            case .click: self = .short
            case .press: self = .startLong
            case .release: self = .endLong
            }
        }
    }

    static func configure() -> Data {
        var writer = ProtobufWriter()
        writer.message(Field.configure) { configure in
            configure.varint(1, features)
            configure.message(2) { info in
                info.string(1, "Sbu Remote")
                info.string(2, "sbu.dev")
                info.varint(3, 1)
                info.string(4, "1")
                info.string(5, "dev.sbu.remote")
                info.string(6, "1.0")
            }
        }
        return writer.data
    }

    static func setActive() -> Data {
        var writer = ProtobufWriter()
        writer.message(Field.setActive) { $0.varint(1, features) }
        return writer.data
    }

    static func pingResponse(_ value: Int) -> Data {
        var writer = ProtobufWriter()
        writer.message(Field.pingResponse) { $0.varint(1, value) }
        return writer.data
    }

    static func key(_ code: Int, action: KeyAction) -> Data {
        var writer = ProtobufWriter()
        writer.message(Field.keyInject) { inject in
            inject.varint(1, code)
            inject.varint(2, Direction(action).rawValue)
        }
        return writer.data
    }

    /// Opens an app by deep link, such as `https://www.youtube.com`.
    static func appLink(_ link: String) -> Data {
        var writer = ProtobufWriter()
        writer.message(Field.appLinkLaunch) { $0.string(1, link) }
        return writer.data
    }

    /// Replaces the text of the TV's active field, with the counters the TV last sent.
    static func text(_ text: String, imeCounter: Int, fieldCounter: Int) -> Data {
        var writer = ProtobufWriter()
        writer.message(Field.imeBatchEdit) { edit in
            edit.varint(1, imeCounter)
            edit.varint(2, fieldCounter)
            edit.message(3) { info in
                info.varint(1, 1)
                info.message(2) { object in
                    object.varint(1, max(text.count - 1, 0))
                    object.varint(2, max(text.count - 1, 0))
                    object.string(3, text)
                }
            }
        }
        return writer.data
    }
}
