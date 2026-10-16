import Foundation

/// Samsung Tizen (2016+) remote control over WebSocket, `samsung.remote.control` channel.
///
/// From public descriptions of the protocol (samsung-tv-ws-api, Home Assistant `samsungtv`,
/// `research/1539090879/protocols.md`). Verified only with unit tests: to check on a real TV
/// are `KEY_PLAY` as play/pause, `KEY_TOOLS` as options, and the app launch action types.
nonisolated enum SamsungMessage {
    /// The name shown in the TV's "Consenti/Nega" prompt and its device list.
    static let clientName = "Sbu Remote"

    /// `wss://host:8002/...` on TVs with token support, `ws://host:8001/...` only on legacy
    /// models the user confirmed (`TransportPolicy`). The token is never put in a plain URL.
    static func remoteURL(host: String, transport: TransportPolicy.Transport, token: String?) -> URL? {
        let secure = transport == .secure
        var components = URLComponents()
        components.scheme = secure ? "wss" : "ws"
        components.host = host
        components.port = secure ? 8002 : 8001
        components.path = "/api/v2/channels/samsung.remote.control"
        // The base64 name goes as clients send it, `=` padding unescaped; only `+` and `/` are escaped.
        let name = Data(clientName.utf8).base64EncodedString()
            .replacingOccurrences(of: "+", with: "%2B")
            .replacingOccurrences(of: "/", with: "%2F")
        var items = [URLQueryItem(name: "name", value: name)]
        if TransportPolicy.mayCarryToken(on: transport), let token, !token.isEmpty, token.allSatisfy({ $0.isLetter || $0.isNumber }) {
            items.append(URLQueryItem(name: "token", value: token))
        }
        components.percentEncodedQueryItems = items
        return components.url
    }

    /// `http://host:8001/api/v2/`: name, model, MAC and token support, without pairing.
    static func deviceInfoURL(host: String) -> URL? {
        URL(string: "http://\(host):8001/api/v2/")
    }

    /// The `KEY_*` code of a key; `nil` for keys Samsung has no code for.
    static func keyCode(for key: RemoteKey) -> String? {
        switch key {
        case .power: "KEY_POWER"
        case .home: "KEY_HOME"
        case .back: "KEY_RETURN"
        case .up: "KEY_UP"
        case .down: "KEY_DOWN"
        case .left: "KEY_LEFT"
        case .right: "KEY_RIGHT"
        case .select: "KEY_ENTER"
        case .volumeUp: "KEY_VOLUP"
        case .volumeDown: "KEY_VOLDOWN"
        case .mute: "KEY_MUTE"
        case .channelUp: "KEY_CHUP"
        case .channelDown: "KEY_CHDOWN"
        case .rewind: "KEY_REWIND"
        case .playPause: "KEY_PLAY"
        case .fastForward: "KEY_FF"
        case .options: "KEY_TOOLS"
        case .source: "KEY_SOURCE"
        case .replay: nil
        }
    }

    /// A key event: `Click` for a tap, `Press` and `Release` around a long press.
    static func key(_ code: String, action: KeyAction) -> String {
        let command = switch action {
        case .click: "Click"
        case .press: "Press"
        case .release: "Release"
        }
        return JSONText.encode([
            "method": "ms.remote.control",
            "params": ["Cmd": command, "DataOfCmd": code, "Option": "false", "TypeOfRemote": "SendRemoteKey"],
        ])
    }

    /// The whole text of the TV's open keyboard, base64 as the protocol wants.
    static func text(_ text: String) -> String {
        JSONText.encode([
            "method": "ms.remote.control",
            "params": ["Cmd": Data(text.utf8).base64EncodedString(), "DataOfCmd": "base64", "TypeOfRemote": "SendInputString"],
        ])
    }

    /// Closes the TV's keyboard, confirming the text.
    static let textEnd = JSONText.encode([
        "method": "ms.remote.control",
        "params": ["TypeOfRemote": "SendInputEnd"],
    ])

    static let installedApps = JSONText.encode([
        "method": "ms.channel.emit",
        "params": ["event": "ed.installedApp.get", "to": "host"],
    ])

    /// Opens an app by its Tizen id. Web apps (type 2) open as deep links, the others natively.
    static func launch(appID: String, appType: Int?) -> String {
        JSONText.encode([
            "method": "ms.channel.emit",
            "params": [
                "event": "ed.apps.launch",
                "to": "host",
                "data": ["appId": appID, "action_type": appType == 2 ? "DEEP_LINK" : "NATIVE_LAUNCH"],
            ] as [String: Any],
        ])
    }
}
