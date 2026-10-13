import SbuKit
import SwiftUI

/// A timer in the list: the time or duration, how it repeats, and its switch.
struct TimerRow: View {
    let timer: SoundTimer
    @Binding var isOn: Bool
    let edit: () -> Void

    var body: some View {
        HStack {
            Button(action: edit) {
                VStack(alignment: .leading, spacing: SbuTheme.space1) {
                    Text(timer.title())
                        .font(.title2.monospacedDigit())
                        .foregroundStyle(isOn ? SbuTheme.ink : SbuTheme.inkMuted)
                    Text("Ferma il suono · \(timer.repeatSummary())")
                        .font(.subheadline)
                        .foregroundStyle(SbuTheme.inkMuted)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(.rect)
            }
            .buttonStyle(.plain)
            .accessibilityHint("Modifica il timer")

            Toggle(timer.title(), isOn: $isOn)
                .labelsHidden()
        }
    }
}

#Preview("Light") {
    List { TimerRow(timer: SoundTimer(), isOn: .constant(true)) {} }
}

#Preview("Dark") {
    List { TimerRow(timer: SoundTimer(trigger: .clock(hour: 23, minute: 30)), isOn: .constant(false)) {} }
        .preferredColorScheme(.dark)
}
