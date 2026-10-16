/// Something that listens for nearby devices: Core Bluetooth on an iPhone, a fixed set in the
/// simulator, screenshots, UI tests and previews.
protocol BluetoothScanner {
    /// Reports the Bluetooth state, then every advertisement heard while it is ready, with
    /// duplicates, so the signal keeps updating. Call `stop()` when done.
    func events() -> AsyncStream<ScanEvent>

    /// Starts listening again from scratch, for Cerca di nuovo.
    func restart()

    /// Stops listening and finishes the stream.
    func stop()
}
