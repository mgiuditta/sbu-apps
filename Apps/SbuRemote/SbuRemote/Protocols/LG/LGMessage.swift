import Foundation

/// LG webOS remote control over SSAP (WebSocket, JSON).
///
/// From public descriptions of the protocol (PyWebOSTV, Home Assistant `webostv`,
/// `research/1539090879/protocols.md`). The manifest asks for permissions without LG's
/// signature: most webOS TVs accept it with the prompt, some firmware may want a signed one.
/// To verify on a real TV, with the URIs of channels, media keys and the IME.
nonisolated enum LGMessage {
    /// `wss://host:3001`, required on recent firmware; `ws://host:3000` on older ones.
    static func url(host: String, secure: Bool) -> URL? {
        URL(string: secure ? "wss://\(host):3001" : "ws://\(host):3000")
    }

    static let registerID = "register_0"

    /// The permissions Sbu Remote asks for in the TV's prompt.
    static let permissions = [
        "LAUNCH", "LAUNCH_WEBAPP", "APP_TO_APP", "CONTROL_AUDIO", "CONTROL_DISPLAY",
        "CONTROL_INPUT_JOYSTICK", "CONTROL_INPUT_MEDIA_PLAYBACK", "CONTROL_INPUT_TEXT",
        "CONTROL_INPUT_TV", "CONTROL_MOUSE_AND_KEYBOARD", "CONTROL_POWER", "READ_APP_STATUS",
        "READ_INPUT_DEVICE_LIST", "READ_INSTALLED_APPS", "READ_NETWORK_STATE", "READ_POWER_STATE",
        "READ_TV_CURRENT_TIME",
    ]

    /// Registration: with the client key the TV gave last time it connects without asking.
    static func register(clientKey: String?) -> String {
        var payload: [String: Any] = [
            "forcePairing": false,
            "pairingType": "PROMPT",
            "manifest": [
                "manifestVersion": 1,
                "appVersion": "1.0",
                "permissions": permissions,
            ] as [String: Any],
        ]
        if let clientKey {
            payload["client-key"] = clientKey
        }
        return JSONText.encode(["type": "register", "id": registerID, "payload": payload])
    }

    static func request(id: String, uri: String, payload: [String: Any]? = nil) -> String {
        var message: [String: Any] = ["type": "request", "id": id, "uri": uri]
        if let payload {
            message["payload"] = payload
        }
        return JSONText.encode(message)
    }

    /// The SSAP URI of the keys that are requests; the others go through the pointer socket.
    static func uri(for key: RemoteKey) -> String? {
        switch key {
        case .power: "ssap://system/turnOff"
        case .volumeUp: "ssap://audio/volumeUp"
        case .volumeDown: "ssap://audio/volumeDown"
        case .channelUp: "ssap://tv/channelUp"
        case .channelDown: "ssap://tv/channelDown"
        case .rewind: "ssap://media.controls/rewind"
        case .fastForward: "ssap://media.controls/fastForward"
        default: nil
        }
    }

    enum URI {
        static let audioStatus = "ssap://audio/getStatus"
        static let setMute = "ssap://audio/setMute"
        static let play = "ssap://media.controls/play"
        static let pause = "ssap://media.controls/pause"
        static let launchPoints = "ssap://com.webos.applicationManager/listLaunchPoints"
        static let launch = "ssap://system.launcher/launch"
        static let inputs = "ssap://tv/getExternalInputList"
        static let switchInput = "ssap://tv/switchInput"
        static let insertText = "ssap://com.webos.service.ime/insertText"
        static let deleteCharacters = "ssap://com.webos.service.ime/deleteCharacters"
        static let sendEnter = "ssap://com.webos.service.ime/sendEnterKey"
        static let pointerSocket = "ssap://com.webos.service.networkinput/getPointerInputSocket"
        static let systemInfo = "ssap://system/getSystemInfo"
        static let networkInfo = "ssap://com.webos.service.connectionmanager/getinfo"
    }
}
