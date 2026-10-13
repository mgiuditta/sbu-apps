import SbuKit
import SwiftUI

/// The line under the top bar while a timer is on, as in the original; tapping it opens the timers.
struct TimerStatusLine: View {
    let date: Date
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Label {
                Text("Si ferma alle \(date, format: format)")
            } icon: {
                Image(systemName: "timer")
                    .fontWeight(.medium)
            }
            .font(.subheadline)
            .foregroundStyle(SbuTheme.inkMuted)
        }
        .buttonStyle(.plain)
        .padding(.vertical, SbuTheme.space2)
    }

    /// The time alone within a day, otherwise with the weekday: "ven 23:30".
    private var format: Date.FormatStyle {
        date.timeIntervalSinceNow < 86_400 ? .dateTime.hour().minute() : .dateTime.weekday(.abbreviated).hour().minute()
    }
}

#Preview("Light") {
    TimerStatusLine(date: .now.addingTimeInterval(1_800)) {}
}

#Preview("Dark") {
    TimerStatusLine(date: .now.addingTimeInterval(200_000)) {}
        .preferredColorScheme(.dark)
}
