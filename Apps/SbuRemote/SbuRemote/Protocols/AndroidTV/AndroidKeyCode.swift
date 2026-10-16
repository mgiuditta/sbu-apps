/// Android `KeyEvent` codes (public Android SDK constants) for the remote's keys.
nonisolated enum AndroidKeyCode {
    static func code(for key: RemoteKey) -> Int? {
        switch key {
        case .home: 3
        case .back: 4
        case .up: 19
        case .down: 20
        case .left: 21
        case .right: 22
        case .select: 23
        case .volumeUp: 24
        case .volumeDown: 25
        case .power: 26
        case .options: 82 // KEYCODE_MENU
        case .playPause: 85
        case .rewind: 89
        case .fastForward: 90
        case .mute: 164 // KEYCODE_VOLUME_MUTE
        case .channelUp: 166
        case .channelDown: 167
        case .source: 178 // KEYCODE_TV_INPUT
        case .replay: 273 // KEYCODE_MEDIA_SKIP_BACKWARD
        }
    }

    /// `KEYCODE_WAKEUP`: turns the TV on without toggling it off when it already is.
    static let wakeUp = 224
    static let enter = 66
}
