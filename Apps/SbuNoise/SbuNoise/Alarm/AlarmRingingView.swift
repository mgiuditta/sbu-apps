import SbuKit
import SwiftUI

/// The ringing alarm, full screen over the player: the time as the figure, then Ferma and
/// Rimanda, big enough to hit half asleep.
struct AlarmRingingView: View {
    let alarm: SoundAlarm
    let soundName: LocalizedStringResource
    let snooze: () -> Void
    let stop: () -> Void

    var body: some View {
        VStack(spacing: SbuTheme.space4) {
            Spacer(minLength: 0)
            Label("Sveglia", systemImage: "alarm")
                .font(SbuTheme.headline)
                .foregroundStyle(SbuTheme.inkMuted)
            TimelineView(.everyMinute) { context in
                ClockFigure(date: context.date)
            }
            Text(soundName)
                .font(SbuTheme.body)
                .foregroundStyle(SbuTheme.inkMuted)
            Spacer(minLength: 0)
            SbuButton("Ferma", action: stop)
            SbuButton("Rimanda di \(SoundAlarm.snoozeLabel(alarm.snoozeMinutes))", kind: .secondary, action: snooze)
        }
        .padding(SbuTheme.space4)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(SbuTheme.paper)
    }
}

#Preview("Light") {
    AlarmRingingView(alarm: SoundAlarm(), soundName: "Rintocchi", snooze: {}, stop: {})
}

#Preview("Dark") {
    AlarmRingingView(alarm: SoundAlarm(), soundName: "Pioggia", snooze: {}, stop: {})
        .preferredColorScheme(.dark)
}
