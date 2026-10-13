import SbuKit
import SwiftUI

/// The time left, the activity's one figure, closed by the full stop as on the Timer: counted by
/// the system while it runs, still while paused, "Fatta" once done.
struct TimerActivityFigure: View {
    @ScaledMetric(relativeTo: .largeTitle) private var size = SbuTheme.statSize

    let face: TimerActivityFace

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 0) {
            figure
                .font(SbuTheme.numberFont(size: size))
                .tracking(SbuTheme.statTracking)
                // Tracking also follows the last glyph: give it back, or it eats the full stop's gap.
                .padding(.trailing, -SbuTheme.statTracking)
                .foregroundStyle(SbuTheme.ink)
                .lineLimit(1)
                .minimumScaleFactor(0.5)

            SbuFullStop(fontSize: size)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(face.isDone ? Text("Fatta") : Text("Tempo rimanente"))
    }

    @ViewBuilder private var figure: some View {
        if let countdown = face.countdown {
            Text(timerInterval: countdown, countsDown: true)
                .monospacedDigit()
                // The system's countdown takes the width of its longest reading: hug the start so the
                // full stop stays close to the last digit.
                .multilineTextAlignment(.leading)
                .fixedSize()
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
