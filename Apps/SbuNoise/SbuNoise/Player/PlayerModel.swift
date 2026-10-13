import Foundation
import Observation

/// What the player shows and plays: the current sound in its list, play/pause and favorites.
@Observable
final class PlayerModel {
    static let lastSoundKey = "lastSoundID"

    let sounds: [Sound]
    /// The page on screen; always a valid index of `sounds`. Remembered for the next launch.
    var index: Int {
        didSet {
            defaults.set(current.id, forKey: Self.lastSoundKey)
            if isPlaying { start() }
        }
    }
    private(set) var isPlaying = false
    /// ponytail: in memory only; saved to the file with the favorites category.
    private(set) var favorites: Set<String> = []
    /// Set when a call or an alarm stops the sound, so it comes back when the system allows.
    @ObservationIgnored private var resumesAfterInterruption = false

    @ObservationIgnored private let engine = SoundEngine()
    @ObservationIgnored private let defaults: UserDefaults
    private static let layerID = "player"

    var current: Sound { sounds[index] }

    /// Opens on the sound played last, or the first one.
    init(sounds: [Sound] = Sound.generated, defaults: UserDefaults = .standard) {
        self.sounds = sounds
        self.defaults = defaults
        let last = defaults.string(forKey: Self.lastSoundKey)
        index = sounds.firstIndex { $0.id == last } ?? 0
    }

    /// The previous or next sound; the buttons wrap at the ends of the list, the swipe stops there.
    func step(_ offset: Int) {
        index = (index + offset + sounds.count) % sounds.count
    }

    func togglePlayback() {
        if isPlaying { pause() } else { start() }
    }

    /// Commands from the lock screen, Control Center, headphones and Siri, and audio session changes.
    func handle(_ event: SystemEvent) {
        switch event {
        case .play: if !isPlaying { start() }
        // Also during a call: the sound must not come back when it ends.
        case .pause: pause()
        case .togglePlayPause: togglePlayback()
        case .next: step(1)
        case .previous: step(-1)
        case .interruptionBegan:
            guard isPlaying else { return }
            pause()
            resumesAfterInterruption = true
        case .interruptionEnded(let shouldResume):
            if resumesAfterInterruption && shouldResume { start() }
            resumesAfterInterruption = false
        case .outputLost:
            pause()
        case .configurationChanged:
            if isPlaying { engine.restart() }
        }
    }

    func isFavorite(_ sound: Sound) -> Bool {
        favorites.contains(sound.id)
    }

    func toggleFavorite(_ sound: Sound) {
        if favorites.remove(sound.id) == nil { favorites.insert(sound.id) }
    }

    private func pause() {
        engine.remove(Self.layerID)
        isPlaying = false
        resumesAfterInterruption = false
    }

    private func start() {
        resumesAfterInterruption = false
        do {
            try engine.addNoise(current.noise, id: Self.layerID)
            isPlaying = true
        } catch {
            // A failed start (another app holds the audio, a call in progress) leaves the player paused.
            isPlaying = false
        }
    }
}
