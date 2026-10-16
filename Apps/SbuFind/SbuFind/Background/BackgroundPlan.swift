import Foundation

/// What runs while Sbu Find is in the background.
///
/// iOS lets a background scan listen only for service UUIDs, so only your saved devices that
/// advertise some can be followed, and only when something needs them: Avvisami se lo perdi on one
/// of them, or Ricorda dove li hai sentiti. Everything else waits for the app to open.
nonisolated enum BackgroundPlan {
    /// How the scanner should listen.
    static func scanMode(isForeground: Bool, saved: [SavedDevice], watchedDeviceID: UUID?, remembersPlaces: Bool) -> ScanMode {
        if isForeground {
            return .foreground
        }
        let followed = saved.filter { device in
            device.canBeFollowedInBackground && (remembersPlaces || device.deviceID == watchedDeviceID)
        }
        let services = Set(followed.flatMap(\.serviceUUIDs)).sorted()
        return services.isEmpty ? .paused : .background(services: services)
    }

    /// Whether Avvisami se lo perdi can keep watching this device with the app in the background:
    /// only a device saved under this identifier that advertises services.
    static func canWatchInBackground(deviceID: UUID, saved: [SavedDevice]) -> Bool {
        saved.contains { $0.deviceID == deviceID && $0.canBeFollowedInBackground }
    }

    /// When the background alert goes off unless the device is heard again: the background
    /// silence after it was last heard, never counting time before the app went to the background
    /// as already spent.
    static func lostDeadline(lastSeen: Date?, enteredBackground: Date, silence: TimeInterval) -> Date {
        max(lastSeen ?? enteredBackground, enteredBackground).addingTimeInterval(silence)
    }
}
