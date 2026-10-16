import Foundation

/// A JSON-RPC reply from a Bravia: `result` on success, `error: [code, message]` otherwise.
nonisolated struct SonyReply {
    let result: [Any]
    let errorCode: Int?

    init?(_ data: Data) {
        guard let json = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any] else { return nil }
        result = json["result"] as? [Any] ?? []
        errorCode = (json["error"] as? [Any])?.first as? Int
    }

    /// IRCC names and codes from `getRemoteControllerInfo` (the second element of `result`).
    var remoteCodes: [String: String] {
        let list = result.count > 1 ? result[1] as? [[String: Any]] ?? [] : []
        var codes: [String: String] = [:]
        for item in list {
            if let name = item["name"] as? String, let value = item["value"] as? String {
                codes[name] = value
            }
        }
        return codes
    }

    /// Items of the first `result` element, as `getApplicationList` and the input list return them.
    private var firstList: [[String: Any]] {
        result.first as? [[String: Any]] ?? []
    }

    var applications: [TVShortcut] {
        firstList.compactMap { item in
            guard let uri = item["uri"] as? String, let title = item["title"] as? String else { return nil }
            return TVShortcut(id: uri, name: title)
        }
    }

    /// Inputs, by the label the user set on the TV or else the input's name ("HDMI 1").
    var inputs: [TVShortcut] {
        firstList.compactMap { item in
            guard let uri = item["uri"] as? String else { return nil }
            let label = (item["label"] as? String).flatMap { $0.isEmpty ? nil : $0 }
            return TVShortcut(id: uri, name: label ?? item["title"] as? String ?? uri)
        }
    }

    var systemInformation: TVDetails {
        let info = result.first as? [String: Any] ?? [:]
        return TVDetails(
            name: info["name"] as? String,
            model: info["model"] as? String,
            macAddress: (info["macAddr"] as? String).flatMap(MACAddress.normalized)
        )
    }

    /// The IR code for a key: the first of its names the TV knows.
    static func code(for key: RemoteKey, in codes: [String: String]) -> String? {
        SonyRequest.irccNames(for: key).lazy.compactMap { codes[$0] }.first
    }
}
