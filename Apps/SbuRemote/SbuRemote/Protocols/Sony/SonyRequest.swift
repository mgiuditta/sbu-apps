import Foundation

/// Sony Bravia IP control: JSON-RPC over HTTP (`/sony/<service>`) and IRCC codes over SOAP.
///
/// From Sony's public Bravia Professional Display documentation (pro-bravia.sony.net, IRCC-IP
/// and REST API). Bravia REST is plain HTTP on the home network: there is no TLS to use.
/// Verified only with unit tests; PIN pairing, the IRCC names and text input need a real Bravia.
nonisolated enum SonyRequest {
    /// The client id the TV lists under its registered devices.
    static let clientID = "SbuRemote:3a6e1c62-8f0b-4f4e-9a59-5bdf3d5d0f10"
    static let nickname = "Sbu Remote"

    enum Service: String {
        case accessControl, system, audio, avContent, appControl
    }

    static func url(host: String, service: Service) -> URL? {
        URL(string: "http://\(host)/sony/\(service.rawValue)")
    }

    static func irccURL(host: String) -> URL? {
        URL(string: "http://\(host)/sony/IRCC")
    }

    static func body(method: String, params: [Any] = [], id: Int = 1, version: String = "1.0") -> Data {
        let object: [String: Any] = ["method": method, "params": params, "id": id, "version": version]
        return Data(JSONText.encode(object).utf8)
    }

    /// Registration that makes the TV show a 4-digit PIN, then (with the PIN) gives the `auth` cookie.
    static let register = body(method: "actRegister", params: [
        ["clientid": clientID, "nickname": nickname, "level": "private"],
        [["value": "yes", "function": "WOL"]],
    ], id: 8)

    /// `Authorization` for the second registration: Basic with an empty user and the PIN as password.
    static func pinAuthorization(_ pin: String) -> String {
        "Basic " + Data(":\(pin)".utf8).base64EncodedString()
    }

    /// The `auth=…` pair from a `Set-Cookie` header.
    static func authCookie(fromSetCookie header: String) -> String? {
        header.components(separatedBy: CharacterSet(charactersIn: ";,"))
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .first { $0.hasPrefix("auth=") && $0.count > 5 }
    }

    /// The SOAP envelope that sends one IR code.
    static func ircc(_ code: String) -> Data {
        let xml = """
        <?xml version="1.0"?><s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/" s:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/"><s:Body><u:X_SendIRCC xmlns:u="urn:schemas-sony-com:service:IRCC:1"><IRCCCode>\(code)</IRCCCode></u:X_SendIRCC></s:Body></s:Envelope>
        """
        return Data(xml.utf8)
    }

    static let irccAction = "\"urn:schemas-sony-com:service:IRCC:1#X_SendIRCC\""

    static let remoteControllerInfo = body(method: "getRemoteControllerInfo", id: 10)
    static let systemInformation = body(method: "getSystemInformation", id: 33)
    static let powerOn = body(method: "setPowerStatus", params: [["status": true]], id: 55)
    static let applications = body(method: "getApplicationList", id: 60)
    static let inputs = body(method: "getCurrentExternalInputsStatus", id: 105)

    static func launch(uri: String) -> Data {
        body(method: "setActiveApp", params: [["uri": uri]], id: 601)
    }

    static func switchInput(uri: String) -> Data {
        body(method: "setPlayContent", params: [["uri": uri]], id: 101)
    }

    static func text(_ text: String) -> Data {
        body(method: "setTextForm", params: [text], id: 601)
    }

    /// IRCC names to try for a key, in order: names differ a little between models.
    static func irccNames(for key: RemoteKey) -> [String] {
        switch key {
        case .power: ["TvPower", "Power", "PowerOff"]
        case .home: ["Home"]
        case .back: ["Return", "Back"]
        case .up: ["Up"]
        case .down: ["Down"]
        case .left: ["Left"]
        case .right: ["Right"]
        case .select: ["Confirm", "DpadCenter"]
        case .volumeUp: ["VolumeUp"]
        case .volumeDown: ["VolumeDown"]
        case .mute: ["Mute"]
        case .channelUp: ["ChannelUp"]
        case .channelDown: ["ChannelDown"]
        case .rewind: ["Rewind"]
        case .playPause: ["Play", "Pause"]
        case .fastForward: ["Forward"]
        case .replay: ["Replay", "Prev"]
        case .options: ["Options", "ActionMenu"]
        case .source: ["Input"]
        }
    }
}
