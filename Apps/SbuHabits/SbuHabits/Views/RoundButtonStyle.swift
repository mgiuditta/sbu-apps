import SbuKit
import SwiftUI

/// A round icon button of a fixed side from the design tokens: filled in the accent with
/// `onAccent` for the one main action, raised paper with `ink` for the others. Use it with a
/// labelled `Button` and `.labelStyle(.iconOnly)`, so VoiceOver reads the label.
struct RoundButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    /// The side: `SbuTheme.controlRoundSm`, `controlRound` or `controlRoundLg`.
    let side: CGFloat
    /// Filled in the accent: the screen's main action.
    var isProminent = false

    /// The symbol's text style, growing with the side.
    private var symbolFont: Font {
        switch side {
        case SbuTheme.controlRoundLg...: SbuTheme.largeTitle
        case SbuTheme.controlRound...: SbuTheme.title2
        default: SbuTheme.body
        }
    }

    private var foreground: AnyShapeStyle {
        guard isEnabled else { return AnyShapeStyle(SbuTheme.inkMuted) }
        return isProminent ? AnyShapeStyle(SbuTheme.onAccent) : AnyShapeStyle(SbuTheme.ink)
    }

    private var background: AnyShapeStyle {
        guard isEnabled else { return AnyShapeStyle(SbuTheme.surfaceSunken) }
        return isProminent ? AnyShapeStyle(.tint) : AnyShapeStyle(SbuTheme.surfaceRaised)
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(symbolFont)
            .fontWeight(.medium)
            .imageScale(.medium)
            // The side is fixed: past the largest text sizes the symbol would spill out.
            .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
            .foregroundStyle(foreground)
            .frame(width: side, height: side)
            .background(background, in: .circle)
            .contentShape(.circle)
            // As SbuButton does.
            .opacity(configuration.isPressed ? 0.7 : 1)
            .accessibilityShowsLargeContentViewer()
    }
}

#Preview("Light") {
    RoundButtonStylePreview()
}

#Preview("Dark") {
    RoundButtonStylePreview()
        .preferredColorScheme(.dark)
}

private struct RoundButtonStylePreview: View {
    var body: some View {
        HStack(spacing: SbuTheme.space6) {
            Button("Avvia", systemImage: "play.fill") {}
                .buttonStyle(RoundButtonStyle(side: SbuTheme.controlRoundSm, isProminent: true))
            Button("Annulla", systemImage: "xmark") {}
                .buttonStyle(RoundButtonStyle(side: SbuTheme.controlRound))
            Button("Pausa", systemImage: "pause.fill") {}
                .buttonStyle(RoundButtonStyle(side: SbuTheme.controlRoundLg, isProminent: true))
        }
        .labelStyle(.iconOnly)
        .padding(SbuTheme.space4)
        .background(SbuTheme.surface)
        .tint(SbuTheme.accentHabits)
    }
}
