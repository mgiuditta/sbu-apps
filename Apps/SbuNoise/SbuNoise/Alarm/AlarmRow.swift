import SbuKit
import SwiftUI

/// An alarm in the list: the time, how it repeats and its sound, and its switch.
struct AlarmRow: View {
    let alarm: SoundAlarm
    let soundName: LocalizedStringResource
    @Binding var isOn: Bool
    let edit: () -> Void

    var body: some View {
        HStack {
            Button(action: edit) {
                VStack(alignment: .leading, spacing: SbuTheme.space1) {
                    Text(alarm.title())
                        .font(.body.monospacedDigit())
                        .foregroundStyle(isOn ? SbuTheme.ink : SbuTheme.inkMuted)
                    Text("Sveglia · \(alarm.repeatSummary()) · \(Text(soundName))")
                        .font(.subheadline)
                        .foregroundStyle(SbuTheme.inkMuted)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(.rect)
            }
            .buttonStyle(.plain)
            .accessibilityHint("Modifica la sveglia")

            Toggle(alarm.title(), isOn: $isOn)
                .labelsHidden()
        }
    }
}

#Preview("Light") {
    List { AlarmRow(alarm: SoundAlarm(), soundName: "Rintocchi", isOn: .constant(true)) {} }
}

#Preview("Dark") {
    List { AlarmRow(alarm: SoundAlarm(hour: 6, minute: 45, weekdays: [2, 3]), soundName: "Pioggia", isOn: .constant(false)) {} }
        .preferredColorScheme(.dark)
}
