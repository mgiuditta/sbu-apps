import SbuKit
import SwiftUI

/// Tody's "Stato": how often, how much work, last done, due, and the dirt bar.
struct ChoreStatusSection: View {
    let chore: Chore
    let state: ChoreState

    var body: some View {
        Section("Stato") {
            LabeledContent("Livello di sporco") {
                Text(state.level, format: .percent.precision(.fractionLength(0)))
                    .monospacedDigit()
            }
            ProgressView(value: state.level)
                .tint(state.status == .paused ? SbuTheme.inkMuted : nil)
                .accessibilityHidden(true)
            LabeledContent("Frequenza") {
                Text(chore.frequency.text)
            }
            LabeledContent("Sforzo") {
                Text(chore.effort.name)
            }
            LabeledContent("Ultima volta") {
                Text(chore.lastDone, format: .dateTime.day().month().year())
            }
            LabeledContent("Scadenza") {
                DueText(label: DueLabel(state))
            }
            LabeledContent("Stanza") {
                Text(chore.room?.name ?? "")
            }
        }
        .listRowBackground(SbuTheme.surfaceRaised)
    }
}

#Preview("Light") {
    ChoreSectionsPreview()
}

#Preview("Dark") {
    ChoreSectionsPreview()
        .preferredColorScheme(.dark)
}
