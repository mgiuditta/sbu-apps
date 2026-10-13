import AVFAudio
import MediaPlayer
import UIKit

/// Connects the player to the system for the app's whole life: commands from the lock screen,
/// Control Center, headphones and Siri, audio session notifications, and the Now Playing card.
///
/// Created once at launch, so the commands work even when iOS starts the app in the background.
final class SystemAudio {
    private let model: PlayerModel
    private let artwork: MPMediaItemArtwork

    init(model: PlayerModel) {
        self.model = model
        artwork = Self.makeArtwork(UIImage(resource: .appIconArtwork))
        observeSession()
        registerCommands()
        updateNowPlaying()
    }

    /// ponytail: observers live as long as the app, so their tokens are never removed.
    private func observeSession() {
        let center = NotificationCenter.default
        let session = AVAudioSession.sharedInstance()
        center.addObserver(forName: AVAudioSession.interruptionNotification, object: session, queue: .main) { [model] note in
            guard let event = SystemEvent(interruption: note.userInfo ?? [:]) else { return }
            MainActor.assumeIsolated { model.handle(event) }
        }
        center.addObserver(forName: AVAudioSession.routeChangeNotification, object: session, queue: .main) { [model] note in
            guard let event = SystemEvent(routeChange: note.userInfo ?? [:]) else { return }
            MainActor.assumeIsolated { model.handle(event) }
        }
        center.addObserver(forName: .AVAudioEngineConfigurationChange, object: nil, queue: .main) { [model] _ in
            MainActor.assumeIsolated { model.handle(.configurationChanged) }
        }
    }

    private func registerCommands() {
        let center = MPRemoteCommandCenter.shared()
        let commands: [(MPRemoteCommand, SystemEvent)] = [
            (center.playCommand, .play),
            (center.pauseCommand, .pause),
            (center.togglePlayPauseCommand, .togglePlayPause),
            (center.nextTrackCommand, .next),
            (center.previousTrackCommand, .previous),
        ]
        for (command, event) in commands {
            command.addTarget { @Sendable [model] _ in
                Task { @MainActor in model.handle(event) }
                return .success
            }
        }
    }

    /// Keeps the lock screen card on the current sound, following the model as it changes.
    private func updateNowPlaying() {
        withObservationTracking {
            MPNowPlayingInfoCenter.default().nowPlayingInfo = [
                MPMediaItemPropertyTitle: String(localized: model.current.name),
                MPMediaItemPropertyArtist: "Sbu Noise",
                MPMediaItemPropertyArtwork: artwork,
                // A sound with no end: no progress bar and no skip by seconds.
                MPNowPlayingInfoPropertyIsLiveStream: true,
                MPNowPlayingInfoPropertyPlaybackRate: model.isPlaying ? 1.0 : 0.0,
            ]
        } onChange: { [weak self] in
            Task { @MainActor in self?.updateNowPlaying() }
        }
    }

    /// The system asks for the image on its own queue, so the handler must not be main-actor isolated.
    private nonisolated static func makeArtwork(_ image: UIImage) -> MPMediaItemArtwork {
        MPMediaItemArtwork(boundsSize: image.size) { _ in image }
    }
}
