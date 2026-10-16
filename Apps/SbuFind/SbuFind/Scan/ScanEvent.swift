/// What a scanner reports: a change of the Bluetooth state, or an advertisement.
nonisolated enum ScanEvent: Equatable, Sendable {
    case state(BluetoothState)
    case advertisement(Advertisement)
}
