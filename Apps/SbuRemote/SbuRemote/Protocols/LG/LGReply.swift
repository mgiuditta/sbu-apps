import Foundation

/// A message from an LG TV: `response`, `registered` or `error`, matched to a request by `id`.
nonisolated struct LGReply {
    let type: String
    let id: String?
    let payload: [String: Any]
    let error: String?

    init?(_ text: String) {
        guard let json = JSONText.decode(text), let type = json["type"] as? String else { return nil }
        self.type = type
        id = json["id"] as? String
        payload = json["payload"] as? [String: Any] ?? [:]
        error = json["error"] as? String
    }

    /// The key to send with the next registration; only in `registered`.
    var clientKey: String? { type == "registered" ? payload["client-key"] as? String : nil }

    /// The TV is showing its prompt and waits for the user.
    var isWaitingForPrompt: Bool { type == "response" && payload["pairingType"] as? String == "PROMPT" }

    var isError: Bool { type == "error" || payload["returnValue"] as? Bool == false }

    /// Apps from `listLaunchPoints`.
    var launchPoints: [TVShortcut] {
        (payload["launchPoints"] as? [[String: Any]] ?? []).compactMap { item in
            guard let id = item["id"] as? String, let title = item["title"] as? String else { return nil }
            return TVShortcut(id: id, name: title)
        }
    }

    /// Inputs from `getExternalInputList`.
    var inputs: [TVShortcut] {
        (payload["devices"] as? [[String: Any]] ?? []).compactMap { item in
            guard let id = item["id"] as? String else { return nil }
            return TVShortcut(id: id, name: item["label"] as? String ?? id)
        }
    }

    /// Address of the pointer socket from `getPointerInputSocket`.
    var socketPath: URL? { (payload["socketPath"] as? String).flatMap(URL.init(string:)) }

    /// Whether the TV is muted, from `audio/getStatus` (`mute` or `muteStatus` by firmware).
    var isMuted: Bool? { payload["mute"] as? Bool ?? payload["muteStatus"] as? Bool }

    var modelName: String? { payload["modelName"] as? String }

    /// The wired MAC when the TV is on a cable, otherwise the Wi-Fi one.
    var macAddress: String? {
        let wired = (payload["wiredInfo"] as? [String: Any])?["macAddress"] as? String
        let wifi = (payload["wifiInfo"] as? [String: Any])?["macAddress"] as? String
        return [wired, wifi].compactMap { $0.flatMap(MACAddress.normalized) }.first
    }
}
