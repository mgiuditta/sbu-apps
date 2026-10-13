import SbuKit
import SwiftUI

/// The original's row of five: favorite, previous, play/pause, next, info; then the device volume
/// and the audio output.
struct PlayerControls: View {
    let model: PlayerModel
    /// The sound's source, or the Mix Pad for a mix.
    let showInfo: () -> Void

    var body: some View {
        VStack(spacing: SbuTheme.space5) {
            HStack {
                FavoriteButton(model: model)
                Spacer()
                ControlButton("Precedente", systemImage: "backward.fill") { model.step(-1) }
                Spacer()
                PlayButton(isPlaying: model.isPlaying, action: model.togglePlayback)
                Spacer()
                ControlButton("Successivo", systemImage: "forward.fill") { model.step(1) }
                Spacer()
                if case .mix = model.current {
                    ControlButton("Modifica il mix", systemImage: "slider.horizontal.3", action: showInfo)
                } else {
                    ControlButton("Informazioni", systemImage: "info.circle", action: showInfo)
                }
            }
            .disabled(model.current == nil)
            HStack(spacing: SbuTheme.space3) {
                SystemVolumeSlider()
                    .frame(height: SbuTheme.controlRoundSm)
                RoutePicker()
                    .frame(width: SbuTheme.controlRoundSm, height: SbuTheme.controlRoundSm)
            }
        }
    }
}

private struct ControlButton: View {
    let title: LocalizedStringKey
    let systemImage: String
    let action: () -> Void

    /// Off in an empty list (no favorites or mixes yet): drawn muted, so it does not look dead.
    @Environment(\.isEnabled) private var isEnabled

    init(_ title: LocalizedStringKey, systemImage: String, action: @escaping () -> Void) {
        self.title = title
        self.systemImage = systemImage
        self.action = action
    }

    var body: some View {
        Button(title, systemImage: systemImage, action: action)
            .labelStyle(.iconOnly)
            .font(.title3.weight(.medium))
            .foregroundStyle(isEnabled ? SbuTheme.ink : SbuTheme.line)
            .frame(width: SbuTheme.controlRoundSm, height: SbuTheme.controlRoundSm)
            .contentShape(.rect)
    }
}

private struct FavoriteButton: View {
    let model: PlayerModel

    var body: some View {
        let isFavorite = model.current.map(model.isFavorite) ?? false
        ControlButton(
            isFavorite ? "Togli dai preferiti" : "Aggiungi ai preferiti",
            systemImage: isFavorite ? "heart.fill" : "heart"
        ) {
            if let current = model.current { model.toggleFavorite(current) }
        }
        .sensoryFeedback(.selection, trigger: isFavorite)
    }
}

private struct PlayButton: View {
    let isPlaying: Bool
    let action: () -> Void

    @Environment(\.isEnabled) private var isEnabled

    var body: some View {
        Button(isPlaying ? "Pausa" : "Riproduci", systemImage: isPlaying ? "pause.fill" : "play.fill", action: action)
            .labelStyle(.iconOnly)
            .font(.title.weight(.medium))
            .foregroundStyle(isEnabled ? SbuTheme.onAccent : SbuTheme.inkMuted)
            .frame(width: SbuTheme.controlRoundLg, height: SbuTheme.controlRoundLg)
            .background(isEnabled ? AnyShapeStyle(.tint) : AnyShapeStyle(SbuTheme.line), in: .circle)
            .contentShape(.circle)
    }
}

#Preview("Light") {
    PlayerControls(model: PlayerModel()) {}
        .padding(SbuTheme.space4)
        .tint(SbuTheme.accentNoise)
}

#Preview("Dark") {
    PlayerControls(model: PlayerModel()) {}
        .padding(SbuTheme.space4)
        .tint(SbuTheme.accentNoise)
        .preferredColorScheme(.dark)
}
