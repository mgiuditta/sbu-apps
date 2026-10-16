import Foundation

/// What a device probably is, guessed from its name and what it advertises: only to pick its symbol.
nonisolated enum DeviceKind: String, CaseIterable, Sendable {
    case earbuds
    case headphones
    case watch
    case laptop
    case phone
    case tablet
    case speaker
    case keyboard
    case mouse
    /// Anything else: trackers, rings, sensors, lights.
    case other

    /// Apple's Continuity "proximity pairing" message, sent by AirPods and Beats out of the case.
    private static let appleProximityPairing: UInt8 = 0x07
    /// Bluetooth SIG Heart Rate service: chest straps and watches.
    private static let heartRateService = "180D"

    /// Name fragments, checked in this order: the first kind with a match wins, so
    /// "AirPods Max" is headphones before "airpods" makes it earbuds, and "Galaxy Buds" is
    /// earbuds before "galaxy" makes it a phone.
    private static let nameRules: [(DeviceKind, [String])] = [
        (.headphones, ["airpods max", "headphone", "headset", "wh-", "quietcomfort", "qc35", "qc45", "beats solo", "beats studio", "momentum"]),
        (.earbuds, ["airpods", "buds", "earbud", "earphone", "wf-", "powerbeats", "beats fit", "beats flex", "elite", "liberty", "freebuds", "nothing ear", "tws", "pods"]),
        (.watch, ["watch", "band", "fitbit", "garmin", "forerunner", "fenix", "venu", "amazfit", "whoop", "polar", "suunto", "coros"]),
        (.laptop, ["macbook", "laptop", "notebook", "thinkpad", "xps"]),
        (.tablet, ["ipad", "galaxy tab", "tablet"]),
        (.phone, ["iphone", "galaxy", "pixel", "phone", "oneplus", "xiaomi", "redmi"]),
        (.speaker, ["speaker", "homepod", "sonos", "soundlink", "jbl flip", "jbl charge", "jbl go", "jbl clip", "boom", "echo", "soundcore motion"]),
        (.keyboard, ["keyboard", "keys"]),
        (.mouse, ["mouse", "mx master", "trackpad"]),
    ]

    init(advertisement: Advertisement) {
        if let name = advertisement.name?.lowercased(),
           let kind = Self.nameRules.first(where: { _, fragments in fragments.contains(where: name.contains) })?.0 {
            self = kind
        } else if advertisement.companyID == Advertisement.appleCompanyID,
                  advertisement.manufacturerMessageType == Self.appleProximityPairing {
            self = .earbuds
        } else if advertisement.serviceUUIDs.contains(where: { $0.uppercased() == Self.heartRateService }) {
            self = .watch
        } else {
            self = .other
        }
    }

    /// What the row says under the name.
    var name: LocalizedStringResource {
        switch self {
        case .earbuds: "Auricolari"
        case .headphones: "Cuffie"
        case .watch: "Orologio o braccialetto"
        case .laptop: "Computer portatile"
        case .phone: "Telefono"
        case .tablet: "Tablet"
        case .speaker: "Altoparlante"
        case .keyboard: "Tastiera"
        case .mouse: "Mouse"
        case .other: "Dispositivo Bluetooth"
        }
    }

    /// The SF Symbol drawn in the row and on the finder.
    var systemImage: String {
        switch self {
        case .earbuds: "airpods"
        case .headphones: "headphones"
        case .watch: "applewatch"
        case .laptop: "laptopcomputer"
        case .phone: "iphone"
        case .tablet: "ipad"
        case .speaker: "hifispeaker"
        case .keyboard: "keyboard"
        case .mouse: "computermouse"
        case .other: "sensor"
        }
    }
}
