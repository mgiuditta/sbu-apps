import SbuKit
import SwiftUI

/// A square icon button of a fixed side from the design tokens, with `radiusCard` corners: filled
/// in `ink` with `paper` for the one main action, raised paper with `ink` for the others. Use it with a
/// labelled `Button` and `.labelStyle(.iconOnly)`, so VoiceOver reads the label. A button can be
/// drawn smaller than it is touched, as play on a small ring: the hit area keeps `side`.
struct RoundButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    /// The side: `SbuTheme.controlRoundSm`, `controlRound` or `controlRoundLg`.
    let side: CGFloat
    /// Filled in `ink`: the screen's main action.
    var isProminent = false
    /// The side of the circle drawn, when smaller than the side touched; `nil` draws `side`.
    var drawnSide: CGFloat?

    private var circleSide: CGFloat {
        min(drawnSide ?? side, side)
    }

    /// The symbol's text style, growing with the circle drawn.
    private var symbolFont: Font {
        switch circleSide {
        case SbuTheme.controlRoundLg...: SbuTheme.largeTitle
        case SbuTheme.controlRound...: SbuTheme.title2
        case SbuTheme.controlRoundSm...: SbuTheme.body
        default: SbuTheme.caption
        }
    }

    /// Past these text sizes the symbol would spill out of the circle drawn.
    private var largestTextSize: DynamicTypeSize {
        circleSide < SbuTheme.controlRoundSm ? .large : .xxxLarge
    }

    private var foreground: AnyShapeStyle {
        guard isEnabled else { return AnyShapeStyle(SbuTheme.inkMuted) }
        return isProminent ? AnyShapeStyle(SbuTheme.paper) : AnyShapeStyle(SbuTheme.ink)
    }

    private var background: AnyShapeStyle {
        guard isEnabled else { return AnyShapeStyle(SbuTheme.surfaceSunken) }
        return isProminent ? AnyShapeStyle(SbuTheme.ink) : AnyShapeStyle(SbuTheme.surfaceRaised)
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(symbolFont)
            .fontWeight(.medium)
            .imageScale(.medium)
            // The side is fixed: past the largest text sizes the symbol would spill out.
            .dynamicTypeSize(...largestTextSize)
            .foregroundStyle(foreground)
            .frame(width: circleSide, height: circleSide)
            .background(background, in: .rect(cornerRadius: SbuTheme.radiusCard))
            // Touched on the whole side, however small the circle drawn.
            .frame(width: side, height: side)
            .contentShape(.rect(cornerRadius: SbuTheme.radiusCard))
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
                .buttonStyle(RoundButtonStyle(side: SbuTheme.controlRoundSm, isProminent: true, drawnSide: SbuTheme.controlRoundXs))
            Button("Avvia", systemImage: "play.fill") {}
                .buttonStyle(RoundButtonStyle(side: SbuTheme.controlRoundSm, isProminent: true))
            Button("Annulla", systemImage: "xmark") {}
                .buttonStyle(RoundButtonStyle(side: SbuTheme.controlRound))
            Button("Pausa", systemImage: "pause.fill") {}
                .buttonStyle(RoundButtonStyle(side: SbuTheme.controlRoundLg, isProminent: true))
        }
        .labelStyle(.iconOnly)
        .padding(SbuTheme.space4)
        .background(SbuTheme.paper)
        .tint(SbuTheme.ink)
    }
}
