import SbuKit
import SwiftUI

/// The countdown on the Lock Screen and in the expanded Dynamic Island: the habit and the time
/// left as the activity's figure, then Pausa or Riprendi, on paper.
struct TimerActivityView: View {
    let face: TimerActivityFace
    let habitID: UUID

    var body: some View {
        HStack(spacing: 0) {
            TimerActivityFigure(face: face)
            TimerActivityButton(face: face, habitID: habitID)
                .padding(.trailing, face.isDone ? 0 : SbuTheme.space4)
        }
        // A Live Activity has a fixed height: past these sizes the figure would be cut.
        .dynamicTypeSize(...DynamicTypeSize.xxLarge)
        .background { SbuPaper(grid: true) }
        .tint(SbuTheme.ink)
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
                    .clipShape(.rect(cornerRadius: SbuTheme.radiusCard))
            }
        }
        .padding(SbuTheme.space4)
        .background(SbuTheme.surfaceSunken)
    }
}
