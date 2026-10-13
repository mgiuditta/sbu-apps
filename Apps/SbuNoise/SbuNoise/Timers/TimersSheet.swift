import SbuKit
import SwiftUI

/// The timers, opened from the bottom bar: each one on or off, tap to change it, swipe to delete.
struct TimersSheet: View {
    let timers: TimersModel

    @Environment(\.dismiss) private var dismiss
    @State private var editing: SoundTimer?

    var body: some View {
        NavigationStack {
            List {
                ForEach(timers.timers) { timer in
                    TimerRow(timer: timer, isOn: isOn(timer)) { editing = timer }
                }
                .onDelete { timers.delete(at: $0) }
            }
            .overlay {
                if timers.timers.isEmpty {
                    ContentUnavailableView("Nessun timer", systemImage: "timer", description: Text("Aggiungi un timer per fermare il suono a un'ora o dopo un po'."))
                }
            }
            .navigationTitle("Timer")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Fine") { dismiss() }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button("Aggiungi", systemImage: "plus") { editing = SoundTimer() }
                }
            }
            .sheet(item: $editing) { timer in
                let isNew = !timers.timers.contains { $0.id == timer.id }
                TimerEditor(timer: timer, isNew: isNew, onSave: timers.save) {
                    timers.delete(timer.id)
                }
            }
        }
    }

    /// Turning a timer on starts its countdown, so the switch goes through the model.
    private func isOn(_ timer: SoundTimer) -> Binding<Bool> {
        Binding { timer.isOn } set: { timers.setOn($0, for: timer.id) }
    }
}

#Preview("Light") {
    TimersSheet(timers: .preview)
        .tint(SbuTheme.accentNoise)
}

#Preview("Dark") {
    TimersSheet(timers: .preview)
        .tint(SbuTheme.accentNoise)
        .preferredColorScheme(.dark)
}
