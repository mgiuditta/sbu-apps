/// A saved device found among the devices heard, and how sure that is.
nonisolated struct DeviceMatch: Equatable, Sendable {
    let device: NearbyDevice
    /// Heard under the identifier it was saved with: it is yours. Otherwise it only says the
    /// same name, kind and maker, which any device can advertise: it is probably yours, and
    /// never counts as yours for its identifier, its places or its Live Activity.
    let isByIdentifier: Bool
}
