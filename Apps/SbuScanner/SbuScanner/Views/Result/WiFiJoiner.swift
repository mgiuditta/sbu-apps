import NetworkExtension

/// Joins the network in a Wi-Fi code; iOS asks the user first.
enum WiFiJoiner {
    nonisolated enum Outcome: Sendable {
        case joined
        case cancelled
        case failed
    }

    static func join(_ network: WiFiNetwork) async -> Outcome {
        let configuration = switch network.security {
        case .open: NEHotspotConfiguration(ssid: network.ssid)
        case .wep: NEHotspotConfiguration(ssid: network.ssid, passphrase: network.password, isWEP: true)
        case .wpa: NEHotspotConfiguration(ssid: network.ssid, passphrase: network.password, isWEP: false)
        }
        configuration.hidden = network.isHidden
        // The network stays known like one joined in Settings, not only while the app is open.
        configuration.joinOnce = false
        do {
            try await NEHotspotConfigurationManager.shared.apply(configuration)
            return .joined
        } catch let error as NSError where error.domain == NEHotspotConfigurationErrorDomain {
            switch NEHotspotConfigurationError(rawValue: error.code) {
            case .alreadyAssociated: return .joined
            case .userDenied: return .cancelled
            default: return .failed
            }
        } catch {
            return .failed
        }
    }
}
