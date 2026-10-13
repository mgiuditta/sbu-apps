import SbuKit
import SwiftUI

/// The line under the top bar while an alarm is on, next to the timer's; tapping it opens them.
struct AlarmStatusLine: View {
    let date: Date
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Label {
                Text("Sveglia alle \(date, format: format)")
            } icon: {
                Image(systemName: "alarm")
                    .fontWeight(.medium)
            }
            .font(.subheadline)
            .foregroundStyle(SbuTheme.inkMuted)
        }
        .buttonStyle(.plain)
        .padding(.vertical, SbuTheme.space2)
    }

    /// The time alone within a day, otherwise with the weekday: "lun 7:00".
    private var format: Date.FormatStyle {
        date.timeIntervalSinceNow < 86_400 ? .dateTime.hour().minute() : .dateTime.weekday(.abbreviated).hour().minute()
    }
}

#Preview("Light") {
    AlarmStatusLine(date: .now.addingTimeInterval(28_800)) {}
}

#Preview("Dark") {
    AlarmStatusLine(date: .now.addingTimeInterval(200_000)) {}
        .preferredColorScheme(.dark)
}
