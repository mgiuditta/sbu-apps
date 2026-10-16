import dnssd
import Network

/// Whether a network error means the user turned off Local Network for the app.
nonisolated enum LocalNetworkAccess {
    /// iOS reports a denied Local Network permission as a DNS-SD policy error on browsers and
    /// connections (Apple TN3179).
    static func isDenied(_ error: NWError) -> Bool {
        if case .dns(let code) = error {
            return code == DNSServiceErrorType(kDNSServiceErr_PolicyDenied)
        }
        return false
    }
}
