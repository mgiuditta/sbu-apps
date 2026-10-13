import SbuKit
import SwiftUI

/// Dormi: the bedside clock, as in the original. The time as the figure, the date, the next alarm
/// and the sound playing, on the dark paper whatever the system appearance, dimmable, with the
/// screen kept on while it is open. When the alarm rings, it rings here.
struct BedsideClockView: View {
    let model: PlayerModel
    let alarms: AlarmsModel

    @Environment(\.dismiss) private var dismiss
    /// How bright the clock is, from barely visible to full; remembered.
    @AppStorage("clockBrightness") private var brightness = 0.6

    var body: some View {
        Group {
            if let ringing = alarms.ringing {
                AlarmRingingView(alarm: ringing, soundName: model.alarmSound(withID: ringing.soundID)?.name ?? Sound.alarmTones[0].name, snooze: alarms.snooze, stop: alarms.stop)
            } else {
                clock
            }
        }
        .background(SbuTheme.surface)
        .preferredColorScheme(.dark)
        .onAppear { UIApplication.shared.isIdleTimerDisabled = true }
        .onDisappear { UIApplication.shared.isIdleTimerDisabled = false }
    }

    private var clock: some View {
        VStack(spacing: SbuTheme.space4) {
            HStack {
                Button("Chiudi", systemImage: "xmark") { dismiss() }
                    .labelStyle(.iconOnly)
                    .font(.title3.weight(.medium))
                    .foregroundStyle(SbuTheme.inkMuted)
                    .frame(width: SbuTheme.controlRoundSm, height: SbuTheme.controlRoundSm)
                    .contentShape(.rect)
                Spacer()
            }
            Spacer(minLength: 0)
            TimelineView(.everyMinute) { context in
                VStack(spacing: SbuTheme.space2) {
                    ClockFigure(date: context.date)
                    Text(context.date, format: .dateTime.weekday(.wide).day().month(.wide))
                        .font(SbuTheme.title2)
                        .foregroundStyle(SbuTheme.inkMuted)
                }
            }
            nextAlarm
            Spacer(minLength: 0)
            ClockSoundRow(model: model)
            BrightnessSlider(brightness: $brightness)
        }
        .padding(SbuTheme.space4)
        .opacity(brightness)
    }

    private var nextAlarm: some View {
        Group {
            if let next = alarms.next {
                Label {
                    Text("Sveglia alle \(next.date, format: .dateTime.hour().minute())")
                } icon: {
                    Image(systemName: "alarm")
                        .fontWeight(.medium)
                }
            } else {
                Label("Nessuna sveglia", systemImage: "alarm")
            }
        }
        .font(SbuTheme.headline)
        .foregroundStyle(SbuTheme.inkMuted)
    }
}

#Preview("Light") {
    let player = PlayerModel()
    BedsideClockView(model: player, alarms: .preview(player: player))
        .tint(SbuTheme.accentNoise)
}

#Preview("Dark") {
    let player = PlayerModel()
    BedsideClockView(model: player, alarms: .preview(player: player))
        .tint(SbuTheme.accentNoise)
        .preferredColorScheme(.dark)
}
