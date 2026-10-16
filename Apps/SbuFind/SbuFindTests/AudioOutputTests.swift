import AVFoundation
import Testing
@testable import SbuFind

struct AudioOutputTests {
    @Test(arguments: [
        (AVAudioSession.Port.bluetoothA2DP, AudioOutput.Kind.bluetooth),
        (.bluetoothHFP, .bluetooth),
        (.bluetoothLE, .bluetooth),
        (.headphones, .wired),
        (.usbAudio, .wired),
        (.builtInSpeaker, .builtIn),
        (.builtInReceiver, .builtIn),
        (.HDMI, .other),
        (.airPlay, .other),
    ])
    func portsMapToKinds(port: AVAudioSession.Port, kind: AudioOutput.Kind) {
        #expect(AudioOutput(port: port, name: "x").kind == kind)
    }

    @Test func onlyBluetoothHeadphonesCanBeRung() {
        #expect(AudioOutput.headphones(in: [AudioOutput(kind: .builtIn, name: "iPhone")]) == nil)
        #expect(AudioOutput.headphones(in: [AudioOutput(kind: .wired, name: "Cuffie")]) == nil)
        #expect(AudioOutput.headphones(in: []) == nil)
        let buds = AudioOutput(kind: .bluetooth, name: "Buds Pro")
        #expect(AudioOutput.headphones(in: [AudioOutput(kind: .other, name: "TV"), buds]) == buds)
    }
}
