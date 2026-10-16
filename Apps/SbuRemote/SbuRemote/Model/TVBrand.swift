import Foundation

/// The TV systems Sbu Remote controls, each through its public local-network protocol.
///
/// Fire TV, Hisense VIDAA and Philips JointSpace stay out (#362): they have no public protocol,
/// or their pairing needs a secret taken from the official app. Roku is postponed (#355).
nonisolated enum TVBrand: String, Codable, CaseIterable, Identifiable, Sendable {
    /// Samsung Tizen, 2016 and later: WebSocket on 8001/8002 and a token.
    case samsung
    /// LG webOS: SSAP over WebSocket on 3000/3001 and a client key.
    case lg
    /// Android TV and Google TV (Sony, TCL, Philips, Xiaomi, Hisense Google TV, Chromecast):
    /// Remote v2, TLS with a client certificate on 6466/6467.
    case androidTV
    /// Sony Bravia that is not Android TV: REST and IRCC over HTTP with a pre-shared key or a PIN.
    case sony

    var id: Self { self }

    /// The system's name, the same in every language.
    var displayName: String {
        switch self {
        case .samsung: "Samsung"
        case .lg: "LG"
        case .androidTV: "Android TV · Google TV"
        case .sony: "Sony Bravia"
        }
    }
}
