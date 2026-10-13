import SbuKit
import SwiftUI

/// The time left, the activity's one figure: counted by the system while it runs, still while
/// paused, "Fatta" once done.
///
/// The full stop comes only with "Fatta": the system's countdown takes the width of its longest
/// reading, so a square after it would float away from the last digit, and a countdown still
/// open has nothing to close yet. Done, the activity closes with its full stop, as Sbu does.
struct TimerActivityFigure: View {
    @ScaledMetric(relativeTo: .largeTitle) private var size = SbuTheme.statSize

    let face: TimerActivityFace

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 0) {
            figure
                .font(SbuTheme.numberFont(size: size))
                .tracking(SbuTheme.statTracking)
                // Tracking also follows the last glyph: give it back, or it eats the full stop's gap.
                .padding(.trailing, face.isDone ? -SbuTheme.statTracking : 0)
                .foregroundStyle(SbuTheme.ink)
                .lineLimit(1)

            if face.isDone {
                SbuFullStop(fontSize: size)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(face.isDone ? Text("Fatta") : Text("Tempo rimanente"))
    }

    @ViewBuilder private var figure: some View {
        if let countdown = face.countdown {
            // Never `fixedSize()` here: the Live Activity then fails to draw at all.
            Text(timerInterval: countdown, countsDown: true)
        } else if let remaining = face.remaining {
            Text(remaining, format: face.clock)
                .accessibilityValue(Text(remaining, format: TimerFormat.spoken))
        } else {
            Text("Fatta")
        }
    }
}

#Preview("Light") {
    TimerActivityFigurePreview()
}

#Preview("Dark") {
    TimerActivityFigurePreview()
        .preferredColorScheme(.dark)
}

private struct TimerActivityFigurePreview: View {
    var body: some View {
        VStack(alignment: .leading, spacing: SbuTheme.space2) {
            TimerActivityFigure(face: TimerActivityFace(attributes: .preview, state: .previewRunning))
            TimerActivityFigure(face: TimerActivityFace(attributes: .preview, state: .previewPaused))
            TimerActivityFigure(face: TimerActivityFace(attributes: .preview, state: .done))
        }
        .padding(SbuTheme.space4)
        .background(SbuTheme.surface)
        .tint(SbuTheme.accentHabits)
    }
}
