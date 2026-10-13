/// What the long press on a card shows. No place name: it would need the network.
nonisolated struct MediaDetails: Equatable, Sendable {
    var fileName: String?
    /// Make and model of the camera, from the picture's metadata.
    var camera: String?
    var lens: String?
}
