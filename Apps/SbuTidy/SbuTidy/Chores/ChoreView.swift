import SbuKit
import SwiftData
import SwiftUI

/// Tody's chore screen: days to its due day as the figure, its state, "Fatta ora",
/// "Fatta il…", "Pausa", the notes and the history.
struct ChoreView: View {
    let chore: Chore

    @Environment(\.modelContext) private var modelContext
    @Environment(\.calendar) private var calendar
    @Environment(\.dismiss) private var dismiss
    @Environment(Clock.self) private var clock
    @State private var isEditing = false
    @State private var isPickingDay = false
    @State private var doneCount = 0

    var body: some View {
        // A one-off chore done, or a chore deleted from its form, is gone before the screen is.
        if chore.isDeleted || chore.modelContext == nil {
            Color.clear
        } else {
            content
        }
    }

    private var content: some View {
        let state = chore.state(at: clock.now, calendar: calendar)
        return List {
            Section {
                ChoreFigure(state: state)
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
            }
            ChoreActionsSection(isPaused: state.status == .paused, isOneOff: chore.isOneOff, markDoneNow: markDoneNow, pickDay: pickDay, togglePause: togglePause)
            ChoreStatusSection(chore: chore, state: state)
            if !chore.notes.isEmpty {
                Section("Note") {
                    Text(chore.notes)
                        .font(SbuTheme.body)
                        .foregroundStyle(SbuTheme.ink)
                        .textSelection(.enabled)
                        .listRowBackground(SbuTheme.surfaceRaised)
                }
            }
            ChoreHistorySection(chore: chore)
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(SbuTheme.surface)
        .navigationTitle(chore.name)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Modifica", action: edit)
                    .tint(SbuTheme.ink)
                    .accessibilityIdentifier("editChore")
            }
        }
        .sheet(isPresented: $isEditing) {
            if let room = chore.room {
                ChoreForm(room: room, chore: chore)
            }
        }
        .sheet(isPresented: $isPickingDay) {
            DoneOnSheet(markDone: markDone)
        }
        .sensoryFeedback(.success, trigger: doneCount)
    }

    private func markDoneNow() {
        markDone(at: .now)
    }

    private func markDone(at date: Date) {
        if chore.isOneOff { dismiss() }
        chore.markDone(at: date, in: modelContext)
        try? modelContext.save()
        clock.refresh()
        doneCount += 1
    }

    private func pickDay() {
        isPickingDay = true
    }

    private func togglePause() {
        if chore.clock.isPaused {
            chore.resume()
        } else {
            chore.pause()
        }
        try? modelContext.save()
        clock.refresh()
    }

    private func edit() {
        isEditing = true
    }
}

#Preview("Light") {
    ChoreViewPreview()
}

#Preview("Dark") {
    ChoreViewPreview()
        .preferredColorScheme(.dark)
}

private struct ChoreViewPreview: View {
    @Query private var chores: [Chore]

    var body: some View {
        NavigationStack {
            if let chore = chores.first(where: { !($0.completions ?? []).isEmpty }) {
                ChoreView(chore: chore)
            }
        }
        .modelContainer(.preview)
        .environment(Clock())
        .tint(SbuTheme.accentTidy)
    }
}
