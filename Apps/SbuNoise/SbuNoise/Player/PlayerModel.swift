import Foundation
import Observation

/// What the player shows and plays: the current sound or mix in its category, play/pause,
/// favorites, and the mix being edited on the Mix Pad.
@Observable
final class PlayerModel {
    static let lastSoundKey = "lastSoundID"
    static let lastCategoryKey = "lastCategory"

    let sounds: [Sound]
    let library: Library

    var category: PlayerCategory {
        didSet {
            guard category != oldValue else { return }
            defaults.set(category.rawValue, forKey: Self.lastCategoryKey)
            index = 0
        }
    }
    /// The page on screen, an index of `items`. Remembered for the next launch.
    var index: Int {
        didSet {
            if let current { defaults.set(current.id, forKey: Self.lastSoundKey) }
            if isPlaying { start() }
        }
    }
    private(set) var isPlaying = false
    /// ponytail: in memory only; saved to the file with the favorites category.
    private(set) var favorites: Set<String> = []
    /// The mix open on the Mix Pad: it plays instead of the page while you change it.
    @ObservationIgnored private var draft: Mix?
    /// Set when a call or an alarm stops the sound, so it comes back when the system allows.
    @ObservationIgnored private var resumesAfterInterruption = false
    /// Moves the layers that have variance while a mix plays.
    @ObservationIgnored private var wandering: Task<Void, Never>?
    /// When the mix started: the Mix Pad draws the wandering sounds on the same clock.
    @ObservationIgnored private(set) var wanderStart = Date.now

    @ObservationIgnored private let engine = SoundEngine()
    @ObservationIgnored private let defaults: UserDefaults
    private static let soundLayerID = "player"

    /// Opens on the category and the sound or mix played last, or the first sound.
    init(sounds: [Sound] = Sound.generated, library: Library = Library(), defaults: UserDefaults = .standard) {
        self.sounds = sounds
        self.library = library
        self.defaults = defaults
        category = defaults.string(forKey: Self.lastCategoryKey).flatMap(PlayerCategory.init) ?? .sounds
        index = 0
        let last = defaults.string(forKey: Self.lastSoundKey)
        index = items.firstIndex { $0.id == last } ?? 0
    }

    var items: [PlayerItem] {
        switch category {
        case .sounds: sounds.map(PlayerItem.sound)
        case .mixes: library.mixes.map(PlayerItem.mix)
        }
    }

    /// `nil` only in an empty category (no mixes yet).
    var current: PlayerItem? {
        let items = items
        return items.indices.contains(index) ? items[index] : nil
    }

    func sound(withID id: String) -> Sound? {
        sounds.first { $0.id == id }
    }

    /// The previous or next item; the buttons wrap at the ends of the list, the swipe stops there.
    func step(_ offset: Int) {
        let count = items.count
        guard count > 0 else { return }
        index = (index + offset + count) % count
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

    /// Commands from Comandi rapidi, Siri, the widgets and the control.
    func perform(_ command: PlaybackCommand) {
        switch command {
        case .play(let itemID):
            if let itemID { select(itemID) }
            // Changing page already restarts a playing sound.
            if !isPlaying { start() }
        case .pause:
            pause()
        }
    }

    /// Moves to the sound or mix with this id, in its category; an unknown id stays where it is.
    private func select(_ itemID: String) {
        if let soundIndex = sounds.firstIndex(where: { $0.id == itemID }) {
            category = .sounds
            index = soundIndex
        } else if let mixIndex = library.mixes.firstIndex(where: { $0.id.uuidString == itemID }) {
            category = .mixes
            index = mixIndex
        }
    }

    func isFavorite(_ item: PlayerItem) -> Bool {
        favorites.contains(item.id)
    }

    func toggleFavorite(_ item: PlayerItem) {
        if favorites.remove(item.id) == nil { favorites.insert(item.id) }
    }

    /// Fades the sound out over `duration`, then pauses it. If the sound was restarted meanwhile
    /// (the output back at full volume) the user's choice wins and it keeps playing.
    func fadeOut(over duration: Duration) async {
        guard isPlaying else { return }
        await engine.fadeOutput(to: 0, over: duration)
        if Task.isCancelled {
            engine.outputVolume = 1
        } else if engine.outputVolume < 0.01 {
            pause()
        }
    }

    // MARK: Mix Pad

    /// Plays `mix` while the Mix Pad changes it: new or removed sounds rebuild the layers, the rest
    /// only moves their settings.
    func preview(_ mix: Mix) {
        let sameLayers = draft?.layers.map(\.id) == mix.layers.map(\.id)
        draft = mix
        if isPlaying && sameLayers {
            apply(mix)
        } else {
            start()
        }
    }

    /// Back to the page after the Mix Pad, playing it if the mix was playing.
    func endPreview() {
        guard draft != nil else { return }
        draft = nil
        if isPlaying { start() }
    }

    /// Saves the mix from the Mix Pad and plays it from its page in Mix.
    func saveAndPlay(_ mix: Mix) {
        library.save(mix)
        draft = nil
        category = .mixes
        index = library.mixes.firstIndex { $0.id == mix.id } ?? 0
        start()
    }

    /// Deletes a mix, staying on a valid page.
    func delete(_ mix: Mix) {
        let wasPlaying = isPlaying && current?.id == mix.id.uuidString
        draft = nil
        library.delete(mix.id)
        if wasPlaying { pause() }
        index = min(index, max(0, items.count - 1))
    }

    // MARK: Playback

    private func pause() {
        wandering?.cancel()
        engine.removeAll()
        isPlaying = false
        resumesAfterInterruption = false
    }

    private func start() {
        resumesAfterInterruption = false
        wandering?.cancel()
        engine.replaceAll()
        engine.outputVolume = 1
        do {
            if let mix = draft ?? current.flatMap(Self.mix) {
                try play(mix)
            } else if case .sound(let sound) = current {
                try engine.addNoise(sound.noise, id: Self.soundLayerID)
            } else {
                return pause()
            }
            isPlaying = true
        } catch {
            // A failed start (another app holds the audio, a call in progress) leaves the player paused.
            pause()
        }
    }

    private func play(_ mix: Mix) throws {
        for layer in mix.layers {
            guard let sound = sound(withID: layer.soundID) else { continue }
            try engine.addNoise(sound.noise, id: layer.id.uuidString)
        }
        wanderStart = .now
        apply(mix)
        // ponytail: 20 updates a second for every mix, even with no variance; cheap next to the audio.
        wandering = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(for: .milliseconds(50))
                guard let self, let mix = self.draft ?? self.current.flatMap(Self.mix) else { return }
                self.apply(mix)
            }
        }
    }

    /// Sets each layer's position, volume and pitch for where it is now on its path.
    private func apply(_ mix: Mix) {
        let time = Date.now.timeIntervalSince(wanderStart)
        for (offset, layer) in mix.layers.enumerated() {
            let id = layer.id.uuidString
            let point = MixSpace.position(of: layer, at: time, phase: Double(offset))
            engine.setPosition(point, for: id)
            engine.setVolume(Float(layer.volume) * MixSpace.gain(at: point), for: id)
            engine.setPitch(Float(layer.pitch), for: id)
        }
    }

    private static func mix(_ item: PlayerItem) -> Mix? {
        if case .mix(let mix) = item { mix } else { nil }
    }
}
