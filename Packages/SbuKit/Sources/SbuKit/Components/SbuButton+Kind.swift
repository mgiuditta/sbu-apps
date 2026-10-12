public extension SbuButton {
    /// The role of an `SbuButton`.
    enum Kind: Sendable {
        /// Filled with the app accent, text in `onAccent`.
        case primary
        /// `surfaceRaised` background, text in the app accent.
        case secondary
        /// `surfaceRaised` background, text in `danger`; asks for confirmation.
        case destructive
    }
}
