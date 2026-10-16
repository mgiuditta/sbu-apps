import CoreBluetooth

/// Whether the app can scan, in the terms the screen cares about.
nonisolated enum BluetoothState: String, CaseIterable, Sendable {
    /// Core Bluetooth has not said yet: the first instant after launch, or while the permission is asked.
    case starting
    /// Bluetooth is restarting; it comes back by itself.
    case resetting
    /// This device has no Bluetooth Low Energy.
    case unsupported
    /// The person said no to Bluetooth for this app.
    case denied
    /// Bluetooth is not allowed for this app by Screen Time or a device profile.
    case restricted
    /// Bluetooth is off.
    case poweredOff
    /// On and allowed: the scan runs.
    case ready

    /// Authorization first: a denied app also sees `.unauthorized`, whatever the radio is doing.
    init(managerState: CBManagerState, authorization: CBManagerAuthorization) {
        switch authorization {
        case .denied:
            self = .denied
            return
        case .restricted:
            self = .restricted
            return
        default:
            break
        }
        switch managerState {
        case .poweredOn: self = .ready
        case .poweredOff: self = .poweredOff
        case .unauthorized: self = .denied
        case .unsupported: self = .unsupported
        case .resetting: self = .resetting
        case .unknown: self = .starting
        @unknown default: self = .starting
        }
    }
}
