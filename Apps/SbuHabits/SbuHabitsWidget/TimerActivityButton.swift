import SbuKit
import SwiftUI

/// Pausa while the countdown runs, Riprendi while it is paused, filled in the accent as on the
/// Timer. They run in the app's process through their intents. Nothing once it is done.
struct TimerActivityButton: View {
    let face: TimerActivityFace
    let habitID: UUID

    var body: some View {
        Group {
            if face.isRunning {
                Button(intent: PauseTimerIntent(habitID: habitID)) {
                    Label("Pausa", systemImage: "pause.fill")
                }
            } else if face.isDone == false {
                Button(intent: ResumeTimerIntent(habitID: habitID)) {
                    Label("Riprendi", systemImage: "play.fill")
                }
            }
        }
        .labelStyle(.iconOnly)
        .buttonStyle(RoundButtonStyle(side: SbuTheme.controlRoundSm, isProminent: true))
        .tint(SbuTheme.ink)
    }
}

#Preview("Light") {
    TimerActivityButtonPreview()
}

#Preview("Dark") {
    TimerActivityButtonPreview()
        .preferredColorScheme(.dark)
}

private struct TimerActivityButtonPreview: View {
    var body: some View {
        HStack(spacing: SbuTheme.space4) {
            TimerActivityButton(face: TimerActivityFace(attributes: .preview, state: .previewRunning), habitID: UUID())
            TimerActivityButton(face: TimerActivityFace(attributes: .preview, state: .previewPaused), habitID: UUID())
        }
        .padding(SbuTheme.space4)
        .background(SbuTheme.paper)
    }
}
