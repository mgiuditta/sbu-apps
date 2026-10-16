import Foundation

/// A Bonjour service a TV announces, as `NWBrowser` reports it, reduced to what discovery needs.
nonisolated struct BonjourRecord: Hashable, Sendable {
    /// Service type, such as `_androidtvremote2._tcp`.
    let type: String
    /// Instance name, which TVs set to the name the user gave them ("Soggiorno").
    let name: String
    /// TXT record keys, lowercased.
    let txt: [String: String]

    init(type: String, name: String, txt: [String: String] = [:]) {
        self.type = type
        self.name = name
        self.txt = Dictionary(txt.map { ($0.key.lowercased(), $0.value) }, uniquingKeysWith: { first, _ in first })
    }

    static let androidTVType = "_androidtvremote2._tcp"
    static let airPlayType = "_airplay._tcp"

    /// The types listed under `NSBonjourServices`.
    static let browsedTypes = [androidTVType, airPlayType]

    /// The brand this service points to. Android TV Remote v2 is Android TV by definition; an
    /// AirPlay receiver tells its maker in `manufacturer` or `model` (to verify on a real TV).
    /// Apple TV and other AirPlay receivers that are not TVs Sbu Remote controls give `nil`.
    var brand: TVBrand? {
        if type == Self.androidTVType { return .androidTV }
        guard type == Self.airPlayType else { return nil }
        let maker = [txt["manufacturer"], txt["model"], txt["md"]].compactMap { $0?.lowercased() }.joined(separator: " ")
        if maker.contains("samsung") { return .samsung }
        if maker.contains("lg") { return .lg }
        if maker.contains("sony") { return .sony }
        return nil
    }

    /// The model, when the TXT record names it.
    var model: String? { txt["model"] ?? txt["md"] }
}
