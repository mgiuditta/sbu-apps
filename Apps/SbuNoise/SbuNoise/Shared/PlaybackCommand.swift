/// What Comandi rapidi, Siri, the widgets and the control ask the player to do.
nonisolated enum PlaybackCommand: Equatable, Sendable {
    /// Plays the sound or mix with this id, or the one on screen for `nil`.
    case play(itemID: String?)
    case pause
}

/// Where the intents send their commands. The app sets `handler` at launch; the intents run in the
/// app's process, so in the widget extension it stays `nil` and nothing happens there.
enum PlaybackCommands {
    static var handler: ((PlaybackCommand) -> Void)?

    static func send(_ command: PlaybackCommand) {
        handler?(command)
    }
}
