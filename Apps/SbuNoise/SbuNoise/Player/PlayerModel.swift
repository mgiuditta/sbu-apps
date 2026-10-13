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
        if isPlaying {
            engine.remove(Self.layerID)
            isPlaying = false
        } else {
            start()
        }
    }

    func isFavorite(_ sound: Sound) -> Bool {
        favorites.contains(sound.id)
    }

    func toggleFavorite(_ sound: Sound) {
        if favorites.remove(sound.id) == nil { favorites.insert(sound.id) }
    }

    private func start() {
        do {
            try engine.addNoise(current.noise, id: Self.layerID)
            isPlaying = true
        } catch {
            // ponytail: a failed start leaves the player paused; background audio surfaces errors.
            isPlaying = false
        }
    }
}
