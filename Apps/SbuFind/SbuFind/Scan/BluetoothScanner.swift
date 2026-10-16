/// Something that listens for nearby devices: Core Bluetooth on an iPhone, a fixed set in the
/// simulator, screenshots, UI tests and previews.
protocol BluetoothScanner {
    /// Reports the Bluetooth state, then every advertisement heard while it is ready. Call
    /// `stop()` when done.
    func events() -> AsyncStream<ScanEvent>

    /// Listens as `mode` says: everything in the foreground, only some services in the
    /// background, or nothing.
    func listen(_ mode: ScanMode)

    /// Starts listening again from scratch in the current mode, for Cerca di nuovo.
    func restart()

    /// Stops listening and finishes the stream.
    func stop()
}
