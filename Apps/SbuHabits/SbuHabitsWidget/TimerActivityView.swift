import SbuKit
import SwiftUI

/// The countdown on the Lock Screen and in the expanded Dynamic Island, as Streaks lays it out:
/// the ring with the symbol, the title and the whole length over the time left, then Pausa or
/// Riprendi.
struct TimerActivityView: View {
    @ScaledMetric(relativeTo: .largeTitle) private var ringSide = SbuTheme.space12 + SbuTheme.space4

    let face: TimerActivityFace
    let habitID: UUID

    var body: some View {
        HStack(spacing: SbuTheme.space4) {
            TimerActivityRing(face: face)
                .frame(width: ringSide, height: ringSide)

            VStack(alignment: .leading, spacing: 0) {
                TimerActivityHeader(face: face)
                TimerActivityFigure(face: face)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            TimerActivityButton(face: face, habitID: habitID)
        }
        // A Live Activity has a fixed height: past these sizes the figure would be cut.
        .dynamicTypeSize(...DynamicTypeSize.xxLarge)
        .tint(SbuTheme.accentHabits)
    }
}

#Preview("Light") {
    TimerActivityViewPreview()
}

#Preview("Dark") {
    TimerActivityViewPreview()
        .preferredColorScheme(.dark)
}

private struct TimerActivityViewPreview: View {
    var body: some View {
        VStack(spacing: SbuTheme.space4) {
            ForEach([HabitTimerAttributes.ContentState.previewRunning, .previewPaused, .done], id: \.self) { state in
                TimerActivityView(face: TimerActivityFace(attributes: .preview, state: state), habitID: UUID())
                    .padding(SbuTheme.space4)
                    .background(SbuTheme.surface, in: .rect(cornerRadius: SbuTheme.radiusXl))
            }
        }
        .padding(SbuTheme.space4)
        .background(SbuTheme.surfaceSunken)
    }
}
