/// A Wi-Fi network from a `WIFI:S:name;T:WPA;P:password;;` code.
nonisolated struct WiFiNetwork: Equatable, Sendable {
    nonisolated enum Security: String, CaseIterable, Sendable {
        case wpa = "WPA"
        case wep = "WEP"
        case open = "nopass"
    }

    var ssid: String
    var password: String
    var security: Security
    var isHidden: Bool

    init(ssid: String, password: String = "", security: Security = .wpa, isHidden: Bool = false) {
        self.ssid = ssid
        self.password = password
        self.security = security
        self.isHidden = isHidden
    }

    init?(code: String) {
        let fields = FieldList.parse(code, prefix: "WIFI:")
        guard let ssid = fields["S"], !ssid.isEmpty else { return nil }
        let type = fields["T"]?.uppercased() ?? ""
        // WPA2 and WPA3 travel as "WPA" in most codes, but some writers spell them out.
        let security: Security = switch type {
        case "WEP": .wep
        case "NOPASS": .open
        case _ where type.hasPrefix("WPA") || type == "SAE": .wpa
        default: (fields["P"] ?? "").isEmpty ? .open : .wpa
        }
        self.init(ssid: ssid, password: security == .open ? "" : fields["P"] ?? "", security: security, isHidden: fields["H"]?.lowercased() == "true")
    }

    var code: String {
        FieldList.make(prefix: "WIFI:", [
            ("T", security.rawValue),
            ("S", ssid),
            ("P", security == .open ? "" : password),
            ("H", isHidden ? "true" : ""),
        ])
    }
}
