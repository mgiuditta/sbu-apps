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
            // The same sound stays on screen (and playing) if the new list has it.
            let previous = items(in: oldValue)
            let previousID = previous.indices.contains(index) ? previous[index].id : nil
            index = items.firstIndex { $0.id == previousID } ?? 0
        }
    }
    /// The page on screen, an index of `items`. Remembered for the next launch.
    var index: Int {
        didSet {
            if let current { defaults.set(current.id, forKey: Self.lastSoundKey) }
            // Only a different sound restarts: the same one on a new page keeps playing.
            if isPlaying && current?.id != playingID { start() }
        }
    }
    private(set) var isPlaying = false
    /// An alarm plays instead of the sound; see `ring(_:fadeIn:)`.
    private(set) var isRinging = false
    /// Called when the system asks to stop while the alarm rings (lock screen, headphones).
    @ObservationIgnored var ringingStopRequested: (() -> Void)?
    @ObservationIgnored private var fadingIn: Task<Void, Never>?
    /// The page item playing now, to tell a new page from the same item moved to another index.
    @ObservationIgnored private var playingID: String?
    /// The mix open on the Mix Pad: it plays instead of the page while you change it.
    @ObservationIgnored private var draft: Mix?
    /// Set when a call or an alarm stops the sound, so it comes back when the system allows.
    @ObservationIgnored private var resumesAfterInterruption = false
    /// Moves the layers that have variance while a mix plays.
    @ObservationIgnored private var wandering: Task<Void, Never>?
    /// When the mix started: the Mix Pad draws the wandering sounds on the same clock.
    @ObservationIgnored private(set) var wanderStart = Date.now

    @ObservationIgnored private let engine = SoundEngine()
    @ObservationIgnored private let loops = LoopCache()
    @ObservationIgnored private let defaults: UserDefaults
    private static let soundLayerID = "player"
    private static let alarmLayerID = "alarm"

    /// Opens on the category and the sound or mix played last, or the first sound.
    init(sounds: [Sound] = Sound.catalog, library: Library = Library(), defaults: UserDefaults = .standard) {
        self.sounds = sounds
        self.library = library
        self.defaults = defaults
        category = defaults.string(forKey: Self.lastCategoryKey).flatMap(PlayerCategory.init) ?? .sounds
        index = 0
        let last = defaults.string(forKey: Self.lastSoundKey)
        index = items.firstIndex { $0.id == last } ?? 0
    }

    var items: [PlayerItem] {
        items(in: category)
    }

    private func items(in category: PlayerCategory) -> [PlayerItem] {
        switch category {
        case .sounds: visibleSounds.map(PlayerItem.sound)
        case .group(let group): visibleSounds.filter { $0.category == group }.map(PlayerItem.sound)
        case .favorites: library.favorites.compactMap { item(withID: $0) }
        case .mixes: library.mixes.map(PlayerItem.mix)
        }
    }

    /// The sound or mix with this id, wherever it is.
    func item(withID id: String) -> PlayerItem? {
        if let sound = sound(withID: id) { return .sound(sound) }
        return library.mixes.first { $0.id.uuidString == id }.map(PlayerItem.mix)
    }

    /// `nil` only in an empty category (no mixes yet).
    var current: PlayerItem? {
        let items = items
        return items.indices.contains(index) ? items[index] : nil
    }

    func sound(withID id: String) -> Sound? {
        sounds.first { $0.id == id }
    }

    /// The catalog as the player shows it: in the order from Gestisci, without the hidden sounds.
    var visibleSounds: [Sound] {
        library.arrangement.visible(sounds)
    }

    // MARK: Gestisci

    /// The whole catalog in the user's order, hidden sounds included.
    var arrangedSounds: [Sound] {
        library.arrangement.arranged(sounds)
    }

    func isHidden(_ sound: Sound) -> Bool {
        library.arrangement.hidden.contains(sound.id)
    }

    /// Reorders the visible sounds, as `List.onMove` reports it.
    func moveSounds(fromOffsets source: IndexSet, toOffset destination: Int) {
        keepingSelection { library.arrangement.move(fromOffsets: source, toOffset: destination, in: sounds) }
    }

    /// Takes the sound out of the player's lists; mixes and favorites keep playing it.
    func hide(_ sound: Sound) {
        keepingSelection { library.arrangement.hide(sound.id) }
    }

    func show(_ sound: Sound) {
        keepingSelection { library.arrangement.show(sound.id) }
    }

    /// Opens the sound or mix and plays it, as a tap in Gestisci does.
    func playItem(withID itemID: String) {
        perform(.play(itemID: itemID))
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
        // While the alarm rings, play/pause on the lock screen or the headphones stops it.
        if isRinging {
            switch event {
            case .play, .pause, .togglePlayPause: ringingStopRequested?()
            default: break
            }
            return
        }
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

    /// Moves to the sound or mix with this id: in the list on screen if it is there, otherwise in
    /// Suoni or Mix; an unknown or hidden id stays where it is.
    private func select(_ itemID: String) {
        if let here = items.firstIndex(where: { $0.id == itemID }) {
            index = here
        } else if let soundIndex = visibleSounds.firstIndex(where: { $0.id == itemID }) {
            category = .sounds
            index = soundIndex
        } else if let mixIndex = library.mixes.firstIndex(where: { $0.id.uuidString == itemID }) {
            category = .mixes
            index = mixIndex
        }
    }

    func isFavorite(_ item: PlayerItem) -> Bool {
        library.isFavorite(item.id)
    }

    /// In Preferiti the item leaves the list: the player moves to its neighbor.
    func toggleFavorite(_ item: PlayerItem) {
        keepingSelection { library.toggleFavorite(item.id) }
    }

    /// Changes the lists, then shows the same item on its new page, or the nearest page if it left.
    private func keepingSelection(_ change: () -> Void) {
        let selectedID = current?.id
        change()
        let items = items
        index = items.firstIndex { $0.id == selectedID } ?? min(index, max(0, items.count - 1))
    }

    /// Fades the sound out over `duration`, then pauses it. If the sound was restarted meanwhile
    /// (the output back at full volume) the user's choice wins and it keeps playing.
    /// - Returns: `true` if the sound faded out and stopped.
    @discardableResult
    func fadeOut(over duration: Duration) async -> Bool {
        guard isPlaying else { return false }
        await engine.fadeOutput(to: 0, over: duration)
        if Task.isCancelled {
            engine.outputVolume = 1
        } else if engine.outputVolume < 0.01 {
            pause()
            return true
        }
        return false
    }

    // MARK: Alarm

    /// A sound of the catalog or an alarm tone.
    func alarmSound(withID id: String) -> Sound? {
        Sound.alarmTones.first { $0.id == id } ?? sound(withID: id)
    }

    /// Stops whatever plays and rings `sound`, rising from silence over `fadeIn`.
    /// - Returns: `false` if the audio could not start (another app holds it, a call).
    @discardableResult
    func ring(_ sound: Sound, fadeIn: Duration) -> Bool {
        // Swaps the layers but keeps the engine and the session: in the background iOS lets an
        // app keep playing, not start again.
        wandering?.cancel()
        fadingIn?.cancel()
        engine.replaceAll()
        isPlaying = false
        playingID = nil
        resumesAfterInterruption = false
        draft = nil
        engine.outputVolume = fadeIn > .zero ? 0 : 1
        do {
            try add(sound, id: Self.alarmLayerID)
        } catch {
            pause()
            return false
        }
        isRinging = true
        if fadeIn > .zero {
            fadingIn = Task { [engine] in await engine.fadeOutput(to: 1, over: fadeIn) }
        }
        return true
    }

    /// Silences the alarm; the sound for sleeping does not come back.
    func stopRinging() {
        guard isRinging else { return }
        pause()
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
        if wasPlaying { pause() }
        keepingSelection { library.delete(mix.id) }
    }

    // MARK: Playback

    private func pause() {
        wandering?.cancel()
        fadingIn?.cancel()
        isRinging = false
        engine.removeAll()
        isPlaying = false
        playingID = nil
        resumesAfterInterruption = false
    }

    private func start() {
        resumesAfterInterruption = false
        playingID = current?.id
        wandering?.cancel()
        engine.replaceAll()
        engine.outputVolume = 1
        do {
            if let mix = draft ?? current.flatMap(Self.mix) {
                try play(mix)
            } else if case .sound(let sound) = current {
                try add(sound, id: Self.soundLayerID)
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
            try add(sound, id: layer.id.uuidString)
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

    private func add(_ sound: Sound, id: String) throws {
        switch sound.source {
        case .generated(let color):
            try engine.addNoise(color, id: id)
        case .loop:
            guard let url = sound.source.url else { throw CocoaError(.fileNoSuchFile) }
            try engine.addLoop(loops.buffer(for: url), id: id)
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
