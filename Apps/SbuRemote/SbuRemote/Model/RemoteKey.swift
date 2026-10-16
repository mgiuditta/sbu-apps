import SwiftUI

/// A key of the remote, the same for every TV; each protocol maps it to its own code.
nonisolated enum RemoteKey: String, CaseIterable, Codable, Sendable {
    case power, home, back
    case up, down, left, right, select
    case volumeUp, volumeDown, mute
    case channelUp, channelDown
    case rewind, playPause, fastForward, replay, options
    case source

    /// SF Symbol drawn on the key, at `.medium` weight.
    var systemImage: String {
        switch self {
        case .power: "power"
        case .home: "house"
        case .back: "arrow.uturn.backward"
        case .up: "chevron.up"
        case .down: "chevron.down"
        case .left: "chevron.left"
        case .right: "chevron.right"
        case .select: "circle"
        case .volumeUp: "plus"
        case .volumeDown: "minus"
        case .mute: "speaker.slash"
        case .channelUp: "chevron.up"
        case .channelDown: "chevron.down"
        case .rewind: "backward"
        case .playPause: "playpause"
        case .fastForward: "forward"
        case .replay: "gobackward.10"
        case .options: "ellipsis"
        case .source: "rectangle.on.rectangle"
        }
    }

    /// What VoiceOver says and Voice Control listens for.
    var title: LocalizedStringResource {
        switch self {
        case .power: "Accensione"
        case .home: "Home"
        case .back: "Indietro"
        case .up: "Su"
        case .down: "Giù"
        case .left: "Sinistra"
        case .right: "Destra"
        case .select: "OK"
        case .volumeUp: "Alza il volume"
        case .volumeDown: "Abbassa il volume"
        case .mute: "Silenzia"
        case .channelUp: "Canale successivo"
        case .channelDown: "Canale precedente"
        case .rewind: "Riavvolgi"
        case .playPause: "Riproduci o metti in pausa"
        case .fastForward: "Avanti veloce"
        case .replay: "Rivedi"
        case .options: "Opzioni"
        case .source: "Sorgente"
        }
    }

    /// Keys that repeat while held, as on a physical remote.
    var repeatsWhileHeld: Bool {
        switch self {
        case .up, .down, .left, .right, .volumeUp, .volumeDown, .channelUp, .channelDown, .rewind, .fastForward: true
        default: false
        }
    }
}
