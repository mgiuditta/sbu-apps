import SbuKit
import SwiftUI

/// The countdown's habit above the time left, as at the top of the Timer: the clock, the title in
/// uppercase and the whole length.
struct TimerActivityHeader: View {
    let face: TimerActivityFace

    var body: some View {
        HStack(spacing: SbuTheme.space1) {
            Image(systemName: "clock")
                .fontWeight(.medium)
                .imageScale(.medium)
            Text(face.title)
                .textCase(.uppercase)
                .foregroundStyle(SbuTheme.ink)
                .lineLimit(1)
            Text(face.duration, format: face.length)
                .monospacedDigit()
        }
        .font(SbuTheme.subheadline)
        .fontWeight(.semibold)
        .foregroundStyle(SbuTheme.inkMuted)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(face.title)
        .accessibilityValue(Text(face.duration, format: TimerFormat.spoken))
    }
}

#Preview("Light") {
    TimerActivityHeader(face: TimerActivityFace(attributes: .preview, state: .previewPaused))
        .padding(SbuTheme.space4)
        .background(SbuTheme.surface)
}

#Preview("Dark") {
    TimerActivityHeader(face: TimerActivityFace(attributes: .preview, state: .previewPaused))
        .padding(SbuTheme.space4)
        .background(SbuTheme.surface)
        .preferredColorScheme(.dark)
}
