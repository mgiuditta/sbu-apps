import AVFoundation

/// Where the iPhone's sound goes: Bluetooth headphones, wired ones, its own speaker.
nonisolated struct AudioOutput: Equatable, Sendable {
    enum Kind: Equatable, Sendable {
        case bluetooth
        case wired
        case builtIn
        case other
    }

    let kind: Kind
    /// The name the device gives itself, such as "Buds Pro di Giulia".
    let name: String

    init(kind: Kind, name: String) {
        self.kind = kind
        self.name = name
    }

    init(port: AVAudioSession.Port, name: String) {
        switch port {
        case .bluetoothA2DP, .bluetoothHFP, .bluetoothLE:
            kind = .bluetooth
        case .headphones, .usbAudio:
            kind = .wired
        case .builtInSpeaker, .builtInReceiver:
            kind = .builtIn
        default:
            kind = .other
        }
        self.name = name
    }

    /// The Bluetooth headphones among the outputs, if any: only those can be lost and rung.
    static func headphones(in outputs: [AudioOutput]) -> AudioOutput? {
        outputs.first { $0.kind == .bluetooth }
    }
}
