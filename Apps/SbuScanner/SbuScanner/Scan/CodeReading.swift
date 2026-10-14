/// A code just read by the camera or found in a photo.
nonisolated struct CodeReading: Equatable, Hashable, Sendable {
    var raw: String
    var symbology: Symbology
}
