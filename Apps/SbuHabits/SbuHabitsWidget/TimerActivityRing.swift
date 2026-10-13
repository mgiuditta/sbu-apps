import SbuKit
import SwiftUI

/// The countdown's ring with the habit's symbol, as the Timer draws it: it fills in the accent
/// with the time gone by. While it runs the system moves it on its own, from the dates.
struct TimerActivityRing: View {
    let face: TimerActivityFace
    /// The symbol's text style: smaller in the Dynamic Island.
    var symbolFont: Font = SbuTheme.title2

    var body: some View {
        ZStack {
            Group {
                if let countdown = face.countdown {
                    ProgressView(timerInterval: countdown, countsDown: false) {
                        EmptyView()
                    } currentValueLabel: {
                        EmptyView()
                    }
                } else {
                    ProgressView(value: face.progress(at: .now))
                }
            }
            .progressViewStyle(.circular)
            .tint(SbuTheme.accentHabits)

            Image(systemName: face.symbol)
                .font(symbolFont)
                .fontWeight(.medium)
                .imageScale(.medium)
                .foregroundStyle(SbuTheme.ink)
        }
        .accessibilityHidden(true)
    }
}

#Preview("Light") {
    TimerActivityRingPreview()
}

#Preview("Dark") {
    TimerActivityRingPreview()
        .preferredColorScheme(.dark)
}

private struct TimerActivityRingPreview: View {
    var body: some View {
        HStack(spacing: SbuTheme.space4) {
            TimerActivityRing(face: TimerActivityFace(attributes: .preview, state: .previewRunning))
            TimerActivityRing(face: TimerActivityFace(attributes: .preview, state: .previewPaused))
            TimerActivityRing(face: TimerActivityFace(attributes: .preview, state: .done))
        }
        .frame(height: SbuTheme.space12 * 2)
        .padding(SbuTheme.space4)
        .background(SbuTheme.surface)
    }
}
