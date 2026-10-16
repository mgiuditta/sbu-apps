import Foundation

/// A message from a Samsung TV on the remote channel.
nonisolated enum SamsungEvent: Equatable, Sendable {
    /// The user allowed the connection; the token goes in the URL next time.
    case connected(token: String?)
    /// The user pressed "Nega", or the TV allows only listed devices.
    case unauthorized
    /// Nobody answered the prompt on the TV.
    case timedOut
    /// The installed apps, with their Tizen type (2 = web app).
    case installedApps([App])
    case other

    struct App: Equatable, Sendable {
        let id: String
        let name: String
        let type: Int?
    }

    init(_ text: String) {
        guard let json = JSONText.decode(text), let event = json["event"] as? String else {
            self = .other
            return
        }
        let data = json["data"] as? [String: Any]
        switch event {
        case "ms.channel.connect":
            self = .connected(token: data?["token"] as? String ?? (data?["token"] as? Int).map(String.init))
        case "ms.channel.unauthorized":
            self = .unauthorized
        case "ms.channel.timeOut":
            self = .timedOut
        case "ed.installedApp.get":
            let list = (data?["data"] as? [[String: Any]]) ?? []
            self = .installedApps(list.compactMap { item in
                guard let id = item["appId"] as? String, let name = item["name"] as? String else { return nil }
                return App(id: id, name: name, type: item["app_type"] as? Int)
            })
        default:
            self = .other
        }
    }
}
