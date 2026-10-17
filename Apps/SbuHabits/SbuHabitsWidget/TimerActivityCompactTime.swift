import SbuKit
import SwiftUI

/// The time left at the trailing side of the compact Dynamic Island: counted by the system while
/// it runs, still while paused, a checkmark once done. Kept narrow, as the island asks.
struct TimerActivityCompactTime: View {
    let face: TimerActivityFace

    var body: some View {
        Group {
            if let countdown = face.countdown {
                Text(timerInterval: countdown, countsDown: true)
                    .multilineTextAlignment(.trailing)
                    .frame(maxWidth: SbuTheme.space12 + SbuTheme.space2)
            } else if let remaining = face.remaining {
                Text(remaining, format: face.clock)
                    .accessibilityValue(Text(remaining, format: TimerFormat.spoken))
            } else {
                Image(systemName: "checkmark")
                    .fontWeight(.medium)
                    .imageScale(.medium)
            }
        }
        .font(SbuTheme.subheadline)
        .fontWeight(.semibold)
        .monospacedDigit()
        .foregroundStyle(SbuTheme.ink)
        .accessibilityLabel(face.isDone ? Text("Fatta") : Text("Tempo rimanente"))
    }
}

#Preview("Light") {
    TimerActivityCompactTimePreview()
}

#Preview("Dark") {
    TimerActivityCompactTimePreview()
        .preferredColorScheme(.dark)
}

private struct TimerActivityCompactTimePreview: View {
    var body: some View {
        HStack(spacing: SbuTheme.space4) {
            TimerActivityCompactTime(face: TimerActivityFace(attributes: .preview, state: .previewRunning))
            TimerActivityCompactTime(face: TimerActivityFace(attributes: .preview, state: .previewPaused))
            TimerActivityCompactTime(face: TimerActivityFace(attributes: .preview, state: .done))
        }
        .padding(SbuTheme.space4)
        .background(SbuTheme.paper)
    }
}
