import Foundation

/// What `GET http://host:8001/api/v2/` says about a Samsung TV.
nonisolated struct SamsungDeviceInfo: Equatable, Sendable {
    let name: String?
    let model: String?
    let macAddress: String?
    /// 2018+ models want `wss://...:8002` and a token.
    let supportsToken: Bool

    init?(_ data: Data) {
        guard let json = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any],
              let device = json["device"] as? [String: Any]
        else { return nil }
        name = (device["name"] as? String).map { $0.removingPercentEncoding ?? $0 } ?? json["name"] as? String
        model = device["modelName"] as? String
        macAddress = (device["wifiMac"] as? String).flatMap(MACAddress.normalized)
        supportsToken = (device["TokenAuthSupport"] as? String) == "true"
    }
}
