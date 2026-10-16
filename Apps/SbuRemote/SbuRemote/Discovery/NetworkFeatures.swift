import Foundation

/// Network features that depend on what Apple grants the app.
nonisolated enum NetworkFeatures {
    /// Whether the app has `com.apple.developer.networking.multicast` (#360).
    ///
    /// SSDP discovery and broadcast Wake-on-LAN need it. Until Apple grants it the app finds
    /// TVs with Bonjour and by address, and wakes a TV with a unicast magic packet. When it is
    /// granted: add the entitlement to `project.yml` and set this to `true`.
    /// The request text is in `docs/remote-multicast-entitlement.md`.
    static let isMulticastEntitled = false
}
