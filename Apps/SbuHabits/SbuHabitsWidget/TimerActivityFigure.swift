import SbuKit
import SwiftUI

/// The countdown's habit and the time left, the activity's one figure: counted by the system
/// while it runs, still while paused, at zero once done. The full stop waits while it runs and is
/// set at the end, when the app ends the activity after `liveEndDelay`.
///
/// Paused and done it is `SbuLiveFigure`. Running, the system has to count the seconds itself
/// with `Text(timerInterval:)`, which `SbuLiveFigure` cannot take, so the same layout is drawn
/// here: the label, the figure at `figureLive` and the `mark` full stop on paper.
struct TimerActivityFigure: View {
    let face: TimerActivityFace

    var body: some View {
        if let countdown = face.countdown {
            HStack(alignment: .lastTextBaseline, spacing: SbuTheme.space3) {
                Text(face.title)
                    .font(SbuTheme.headline)
                    .foregroundStyle(SbuTheme.ink)
                    .lineLimit(1)
                    .frame(maxWidth: .infinity, alignment: .leading)
                HStack(alignment: .lastTextBaseline, spacing: 0) {
                    // Never `fixedSize()` here: the Live Activity then fails to draw at all. It
                    // takes the width of its longest reading: aligned trailing, the digits keep
                    // to the full stop.
                    Text(timerInterval: countdown, countsDown: true)
                        .font(.sbuFigure(size: SbuTheme.figureLive))
                        .foregroundStyle(SbuTheme.ink)
                        .multilineTextAlignment(.trailing)
                        .lineLimit(1)
                    SbuFullStop(.waiting, size: .mark)
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel(Text("Tempo rimanente"))
            }
            .padding(SbuTheme.space4)
            .background { SbuPaper(grid: true) }
            .environment(\.sbuAccent, .habits)
        } else {
            SbuLiveFigure(
                value: (face.remaining ?? .zero).formatted(face.clock),
                label: Text(face.title),
                fullStop: face.isDone ? .set : .waiting,
                accent: .habits
            )
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
        .background(SbuTheme.paper)
    }
}
