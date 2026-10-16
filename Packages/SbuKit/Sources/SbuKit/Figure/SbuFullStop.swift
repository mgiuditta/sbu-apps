import SwiftUI
import WidgetKit

/// The full stop: a filled square, the one colored cell of the page, that closes the figure.
///
/// `.set` takes the app's accent, `.waiting` is `inkMuted` while there is nothing to count or a
/// process runs, `.absent` keeps the space empty so the figure does not move. When it turns `.set`
/// it arrives from below on `SbuMotion.spring` with the `dot` haptic; it beats when a control marked
/// `.sbuAffectsFigure` changes the figure. Exactly one `.set` per screen or widget. Place it last in
/// an `HStack(alignment: .lastTextBaseline)` with the figure: its bottom edge sits on the baseline.
/// VoiceOver skips it.
public struct SbuFullStop: View {
    /// What the full stop says about the figure.
    public enum State: Sendable, Hashable {
        /// No full stop: nothing on screen is final.
        case absent
        /// Grey: nothing to count yet, or the process is running.
        case waiting
        /// In the accent: the figure is final.
        case set
    }

    /// The side of the square.
    public enum Size: Sendable, Hashable {
        /// One grid cell, 24: closes the hero figure.
        case hero
        /// 16: closes the widget figure and the Closure word.
        case inline
        /// 10: Live Activities and the Lock Screen.
        case mark

        var side: CGFloat {
            switch self {
            case .hero: SbuTheme.fullStopHero
            case .inline: SbuTheme.fullStopInline
            case .mark: SbuTheme.fullStopMark
            }
        }

        var gap: CGFloat {
            switch self {
            case .hero: SbuTheme.space3
            case .inline: SbuTheme.space2
            case .mark: SbuTheme.space1
            }
        }
    }

    private let state: State
    private let side: CGFloat
    private let gap: CGFloat
    private let fill: Fill

    @Environment(\.sbuAccent) private var accent
    @Environment(\.sbuFigurePulse) private var pulse
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.colorScheme) private var colorScheme
    @SwiftUI.State private var arrivals = 0

    /// Creates the full stop.
    /// - Parameters:
    ///   - state: `.set` when the figure is final, `.waiting` while counting, `.absent` for none.
    ///   - size: `.hero` on the tool screen, `.inline` in widgets, `.mark` in Live Activities.
    public init(_ state: State = .set, size: Size = .hero) {
        self.state = state
        side = size.side
        gap = size.gap
        fill = .accent
    }

    /// Creates the v4 full stop, sized from the figure's font.
    @available(*, deprecated, message: "Use SbuFullStop(_:size:) inside SbuFigure.")
    public init(fontSize: CGFloat) {
        state = .set
        side = fontSize * SbuTheme.markSize
        gap = fontSize * SbuTheme.markGap
        fill = .accent
    }

    /// The full stop of the Closure, in `accentOnInk` on the ink block.
    init(onInk size: Size) {
        state = .set
        side = size.side
        gap = size.gap
        fill = .onInk
    }

    public var body: some View {
        Rectangle()
            .fill(color)
            .frame(width: side, height: side)
            // On the Lock Screen the full stop takes the accent the person chose for widgets.
            .widgetAccentable()
            .opacity(state == .absent ? 0 : 1)
            .keyframeAnimator(initialValue: Motion(), trigger: arrivals) { content, motion in
                content.offset(y: motion.offset).opacity(motion.opacity)
            } keyframes: { _ in
                KeyframeTrack(\.offset) {
                    MoveKeyframe(reduceMotion || arrivals == 0 ? 0 : side)
                    SpringKeyframe(0, duration: SbuTheme.motionSpringResponse * 2, spring: Spring(response: SbuTheme.motionSpringResponse, dampingRatio: SbuTheme.motionSpringDamping))
                }
                KeyframeTrack(\.opacity) {
                    MoveKeyframe(reduceMotion ? 1 : 0)
                    LinearKeyframe(1, duration: reduceMotion ? 0 : SbuTheme.motionShort)
                }
            }
            .keyframeAnimator(initialValue: 1.0, trigger: pulse?.count ?? 0) { content, opacity in
                content.opacity(opacity)
            } keyframes: { _ in
                // Reduce Motion: the beat is skipped; only the value changes.
                KeyframeTrack {
                    CubicKeyframe(reduceMotion ? 1 : SbuTheme.motionBeatOpacity, duration: SbuTheme.motionShort / 2)
                    CubicKeyframe(1, duration: SbuTheme.motionShort / 2)
                }
            }
            .padding(.leading, gap)
            .alignmentGuide(.firstTextBaseline) { dimensions in dimensions[.bottom] }
            .alignmentGuide(.lastTextBaseline) { dimensions in dimensions[.bottom] }
            .preference(key: SbuSetFullStopCount.self, value: state == .set && fill == .accent ? 1 : 0)
            .onChange(of: state) { old, new in
                guard new == .set, old != .set else { return }
                arrivals += 1
                SbuSound.playIfEnabled()
            }
            .sbuHaptic(.dot, trigger: arrivals)
            .accessibilityHidden(true)
    }

    private var color: AnyShapeStyle {
        switch (state, fill) {
        case (.waiting, _): AnyShapeStyle(SbuTheme.inkMuted)
        case (_, .onInk): AnyShapeStyle(accent?.onInk ?? SbuTheme.paper)
        default: accent.map { AnyShapeStyle($0.base) } ?? AnyShapeStyle(.tint)
        }
    }

    private enum Fill { case accent, onInk }

    private struct Motion {
        var offset: CGFloat = 0
        var opacity: Double = 1
    }
}

#Preview("Light") {
    SbuFullStopPreview()
}

#Preview("Dark") {
    SbuFullStopPreview()
        .preferredColorScheme(.dark)
}

private struct SbuFullStopPreview: View {
    @State private var state = SbuFullStop.State.waiting

    var body: some View {
        VStack(spacing: SbuTheme.space6) {
            HStack(alignment: .lastTextBaseline, spacing: 0) {
                Text(verbatim: "12")
                    .font(.sbuFigure(size: SbuTheme.figureHeroMax, width: SbuTheme.figureWidthMid))
                    .foregroundStyle(SbuTheme.ink)
                SbuFullStop(state)
            }
            HStack(spacing: SbuTheme.space4) {
                SbuFullStop(.waiting, size: .hero)
                SbuFullStop(.waiting, size: .inline)
                SbuFullStop(.waiting, size: .mark)
            }
            Button(state == .set ? "Attendi" : "Chiudi") {
                state = state == .set ? .waiting : .set
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(SbuTheme.paper)
        .environment(\.sbuAccent, .habits)
    }
}
