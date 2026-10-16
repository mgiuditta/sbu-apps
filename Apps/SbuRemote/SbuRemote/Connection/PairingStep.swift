/// What pairing asks of the user after it starts.
nonisolated enum PairingStep: Equatable, Sendable {
    /// Done: the TV accepted (Samsung and LG after "Consenti" on the TV).
    case paired
    /// The TV shows a code to type: 6 hexadecimal characters on Android TV, 4 digits on Sony.
    case code(length: Int, isHexadecimal: Bool)
}
